-- noice.nvim: thay thế cmdline, messages, notifications bằng floating UI (terminal only)
-- Yêu cầu: nui.nvim (đã cài qua kickstart/plugins/neo-tree.lua), nvim-notify (cài ngay bên dưới)
-- https://github.com/folke/noice.nvim
if vim.g.vscode ~= nil then return end

-- nvim-notify: backend cho view `notify` của noice (thông báo popup góc phải)
vim.pack.add { gh 'rcarriga/nvim-notify', gh 'folke/noice.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
    },
  },
  presets = {
    bottom_search = false, -- / và ? hiện popup giữa màn hình
    command_palette = true, -- : hiện ở giữa màn hình dạng popup
    long_message_to_split = true,
  },
}

require('noice').setup(config)
