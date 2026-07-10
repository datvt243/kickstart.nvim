-- Formatter: conform.nvim
-- Chạy formatter bên ngoài (prettier, stylua...) và apply kết quả vào buffer
-- Hỗ trợ format-on-save và format theo range (visual selection)
-- https://github.com/stevearc/conform.nvim

local function gh(repo)
  return 'https://github.com/' .. repo
end

if vim.g.vscode ~= nil then
  return
end

vim.pack.add {gh 'stevearc/conform.nvim'}
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      lua = true,
      typescript = true,
      javascript = true,
      typescriptreact = true,
      javascriptreact = true,
      vue = true,
      json = true,
      css = true,
      html = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 500 }
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback' -- dùng formatter ngoài, fallback về LSP nếu không có
  },
  formatters_by_ft = {
    typescript = { 'prettierd' },
    javascript = { 'prettierd' },
    javascriptreact = { 'prettierd' },
    typescriptreact = { 'prettierd' },
    vue = { 'prettierd' },
    json = { 'prettierd' },
    css = { 'prettierd' },
    html = { 'prettierd' },
  }
}

-- ### FORMAT KEYMAP
vim.keymap.set({'n', 'v'}, '<leader>f', function()
  require('conform').format {
    async = true
  }
end, {
  desc = '[F]ormat buffer'
})
