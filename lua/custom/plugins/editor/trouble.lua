-- trouble.nvim: danh sách đẹp cho diagnostics/quickfix/loclist/LSP references (terminal only)
-- https://github.com/folke/trouble.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/trouble.nvim' }

require('trouble').setup {}

-- ### TROUBLE.NVIM
-- <leader>xx → toggle diagnostics (toàn workspace)
-- <leader>xX → toggle diagnostics (chỉ buffer hiện tại)
-- <leader>xs → toggle symbols
-- <leader>xr → toggle LSP references/definitions
-- <leader>xl → toggle location list
-- <leader>xq → toggle quickfix list
vim.keymap.set('n', '<leader>xx', '<cmd>Trouble diagnostics toggle<CR>', {
  desc = 'Diagnostics (Trouble)',
})

vim.keymap.set('n', '<leader>xX', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', {
  desc = 'Buffer diagnostics (Trouble)',
})

vim.keymap.set('n', '<leader>xs', '<cmd>Trouble symbols toggle focus=false<CR>', {
  desc = 'Symbols (Trouble)',
})

vim.keymap.set('n', '<leader>xr', '<cmd>Trouble lsp toggle focus=false win.position=right<CR>', {
  desc = 'LSP references (Trouble)',
})

vim.keymap.set('n', '<leader>xl', '<cmd>Trouble loclist toggle<CR>', {
  desc = 'Location list (Trouble)',
})

vim.keymap.set('n', '<leader>xq', '<cmd>Trouble qflist toggle<CR>', {
  desc = 'Quickfix list (Trouble)',
})
