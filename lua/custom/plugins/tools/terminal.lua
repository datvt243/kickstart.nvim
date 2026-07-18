-- toggleterm.nvim — terminal nhỏ ở bottom, giống VSCode (terminal only)
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'akinsho/toggleterm.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  size = 15,
  direction = 'horizontal',
  shade_terminals = true,
}

require('toggleterm').setup(config)

-- ### TERMINAL KEYMAPS
-- <leader>tt → toggle terminal (normal + terminal mode)
-- Bật/tắt terminal ở bottom từ normal mode
vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
-- Bật/tắt terminal ở bottom từ bên trong terminal mode (không cần thoát về normal trước)
vim.keymap.set('t', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
