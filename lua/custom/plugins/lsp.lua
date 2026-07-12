-- LSP: nvim-lspconfig + Mason + fidget + tiny-inline-diagnostic (terminal only)
-- nvim-lspconfig: cấu hình LSP client cho từng ngôn ngữ (ts_ls, lua_ls, gopls, eslint...)
-- Mason (+ mason-lspconfig, mason-tool-installer): tự cài LSP server khai báo trong `servers`
-- fidget: hiển thị tiến trình LSP ở góc màn hình
-- tiny-inline-diagnostic: hiển thị lỗi/warning inline giống Error Lens (tắt virtual_text mặc định)
-- lazydev (type Neovim API cho lua_ls): xem lua/custom/plugins/coding/lazydev.lua
-- https://github.com/neovim/nvim-lspconfig
-- https://github.com/mason-org/mason.nvim
-- https://github.com/j-hui/fidget.nvim
-- https://github.com/rachartier/tiny-inline-diagnostic.nvim
-- Keymap nổi bật: gd/gk/grn/gra/grD, <leader>th toggle inlay hints — marker ### LSP KEYMAPS bên dưới
local function gh(repo) return 'https://github.com/' .. repo end

if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

vim.pack.add { gh 'rachartier/tiny-inline-diagnostic.nvim' }
require('tiny-inline-diagnostic').setup {}
vim.diagnostic.config { virtual_text = false }

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', {
    clear = true,
  }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, {
        buffer = event.buf,
        desc = 'LSP: ' .. desc,
      })
    end

    -- ### LSP KEYMAPS
    -- Đổi tên symbol và cập nhật tất cả references trong workspace
    map('grn', vim.lsp.buf.rename, 'Đổi tên symbol')
    -- Hiển thị danh sách code action tại cursor (quick fix, import thiếu, extract...)
    map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    -- Nhảy đến nơi định nghĩa symbol (thay thế Ctrl+click)
    map('gd', vim.lsp.buf.definition, 'Goto definition')
    -- Xem tài liệu / kiểu của symbol dưới cursor trong popup
    map('gk', vim.lsp.buf.hover, 'Hover documentation')
    -- Nhảy đến declaration (thường là prototype/header, khác với definition)
    map('grD', vim.lsp.buf.declaration, 'Goto declaration')

    -- Highlight tất cả references của symbol dưới cursor
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', {
        clear = false,
      })
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
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', {
          clear = true,
        }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds {
            group = 'kickstart-lsp-highlight',
            buffer = event2.buf,
          }
        end,
      })
    end

    -- Toggle inlay hints nếu LSP hỗ trợ
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      -- Bật/tắt inlay hints (hiển thị type annotation inline trong code)
      map(
        '<leader>th',
        function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled {
            bufnr = event.buf,
          })
        end,
        'Toggle Inlay Hints'
      )
    end
  end,
})

-- Danh sách LSP servers — Mason sẽ tự cài khi khởi động
-- Thêm/xóa server theo nhu cầu của project
---@type table<string, vim.lsp.Config>
local servers = {
  ts_ls = {}, -- TypeScript / JavaScript
  gopls = {}, -- Go
  eslint = {
    on_attach = function(_, bufnr)
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = vim.api.nvim_create_augroup('eslint-fix-on-save-' .. bufnr, {
          clear = true,
        }),
        buffer = bufnr,
        command = 'EslintFixAll',
      })
    end,
  }, -- Linting JS/TS + auto-fix on save
  stylua = {}, -- Formatter Lua (dùng bởi conform.nvim)
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), { '${3rd}/luv/library', '${3rd}/busted/library' }),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = {
          enable = false,
        },
      },
    },
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
require('mason-tool-installer').setup {
  ensure_installed = ensure_installed,
}

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
