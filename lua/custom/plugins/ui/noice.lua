-- noice.nvim: thay thế cmdline, messages, notifications bằng floating UI (terminal only)
-- Yêu cầu: nui.nvim (đã cài qua kickstart/plugins/neo-tree.lua)
-- https://github.com/folke/noice.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/noice.nvim' }

require('noice').setup {
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
