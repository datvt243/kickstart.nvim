-- Claude Code integration (terminal only)
-- Tích hợp Claude Code CLI vào Neovim: toggle terminal, gửi selection, accept/deny diff
if vim.g.vscode ~= nil then return end

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'coder/claudecode.nvim' }

require('claudecode').setup {}

-- ### CLAUDE CODE
-- <leader>cc → toggle Claude Code terminal
-- <leader>cs → gửi selection hiện tại đến Claude (visual mode)
-- <leader>ca → accept diff (khi Claude đề xuất thay đổi)
-- <leader>cd → deny diff
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<cr>',           { desc = '[C]laude [C]ode toggle' })
vim.keymap.set('v', '<leader>cs', '<cmd>ClaudeCodeSend<cr>',       { desc = '[C]laude [S]end selection' })
vim.keymap.set('n', '<leader>ca', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = '[C]laude [A]ccept diff' })
vim.keymap.set('n', '<leader>cd', '<cmd>ClaudeCodeDiffDeny<cr>',   { desc = '[C]laude [D]eny diff' })
