-- LSP: nvim-lspconfig + Mason
-- nvim-lspconfig: cấu hình LSP client cho từng ngôn ngữ (ts_ls, lua_ls...)
-- Mason: cài đặt và quản lý LSP servers, formatter, linter tự động
-- fidget: hiển thị tiến trình LSP ở góc màn hình
-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/mason-org/mason.nvim
-- https://github.com/j-hui/fidget.nvim

local function gh(repo) return 'https://github.com/' .. repo end

if vim.g.vscode ~= nil then return end

-- fidget: hiển thị tiến trình LSP ở góc màn hình
vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    -- ### LSP KEYMAPS
    map('grn', vim.lsp.buf.rename, 'Đổi tên symbol')
    map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    map('gd', vim.lsp.buf.definition, 'Goto definition')
    map('gk', vim.lsp.buf.hover, 'Hover documentation')
    map('grD', vim.lsp.buf.declaration, 'Goto declaration')

    -- Highlight tất cả references của symbol dưới cursor
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- Toggle inlay hints nếu LSP hỗ trợ
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
      end, 'Toggle Inlay Hints')
    end
  end,
})

-- Danh sách LSP servers — Mason sẽ tự cài khi khởi động
-- Thêm/xóa server theo nhu cầu của project
---@type table<string, vim.lsp.Config>
local servers = {
  ts_ls = {},   -- TypeScript / JavaScript
  eslint = {},  -- Linting JS/TS
  stylua = {},  -- Formatter Lua (dùng bởi conform.nvim)
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config'
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
            '${3rd}/luv/library',
            '${3rd}/busted/library',
          }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = { Lua = { format = { enable = false } } },
  },
}

vim.pack.add {
  gh 'neovim/nvim-lspconfig',
  gh 'mason-org/mason.nvim',
  gh 'mason-org/mason-lspconfig.nvim',
  gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

require('mason').setup {}

local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- Thêm tool khác nếu cần, vd: 'prettier', 'black', 'pyright'
})
require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
