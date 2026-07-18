-- conform.nvim: chạy formatter bên ngoài (prettier, stylua...) và apply kết quả vào buffer (terminal only)
-- Hỗ trợ format-on-save và format theo range (visual selection)
-- https://github.com/stevearc/conform.nvim
-- Keymap nổi bật: <leader>qf format, <leader>qF chọn formatter, <leader>qc đổi filetype — marker ### FORMAT KEYMAP

if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'stevearc/conform.nvim' }

-- xmllint có sẵn trên macOS (libxml2) nhưng KHÔNG có sẵn trên Windows → chọn formatter XML đầu tiên
-- khả dụng trên máy; không có cái nào thì bỏ hẳn key xml để conform fallback về LSP, tránh giả định chỉ-macOS.
local function first_available(cmds)
  for _, c in ipairs(cmds) do
    if vim.fn.executable(c) == 1 then return c end
  end
end

local formatters_by_ft = {
  typescript = { 'prettierd' },
  javascript = { 'prettierd' },
  javascriptreact = { 'prettierd' },
  typescriptreact = { 'prettierd' },
  vue = { 'prettierd' },
  json = { 'prettierd' },
  css = { 'prettierd' },
  html = { 'prettierd' },
}

local xml_formatter = first_available { 'xmllint', 'xmlformat', 'tidy' }
if xml_formatter then formatters_by_ft.xml = { xml_formatter } end

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
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
      xml = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end
  end,
  default_format_opts = {
    lsp_format = 'fallback', -- dùng formatter ngoài, fallback về LSP nếu không có
  },
  formatters_by_ft = formatters_by_ft,
}

require('conform').setup(config)

-- ### FORMAT KEYMAP
-- Format buffer (normal) hoặc selection (visual) bằng formatter cấu hình trong formatters_by_ft
vim.keymap.set({ 'n', 'v' }, '<leader>qf', function()
  require('conform').format {
    async = true,
  }
end, {
  desc = 'Format current file',
})

-- Format buffer với formatter tự chọn (hiện danh sách formatter khả dụng cho filetype hiện tại)
vim.keymap.set({ 'n', 'v' }, '<leader>qF', function()
  local conform = require 'conform'
  local formatters = conform.list_formatters_for_buffer(0)
  if #formatters == 0 then
    vim.notify('Không có formatter nào cho filetype này', vim.log.levels.WARN)
    return
  end
  vim.ui.select(formatters, { prompt = 'Format current file with...' }, function(choice)
    if choice then conform.format { formatters = { choice }, async = true } end
  end)
end, {
  desc = 'Format current file with...',
})

-- Đổi filetype của buffer hiện tại (tương đương "change language mode")
vim.keymap.set('n', '<leader>qc', function()
  vim.ui.input({
    prompt = 'Filetype: ',
    default = vim.bo.filetype,
    completion = 'filetype',
  }, function(input)
    if input and input ~= '' then vim.bo.filetype = input end
  end)
end, {
  desc = 'Change language mode',
})
