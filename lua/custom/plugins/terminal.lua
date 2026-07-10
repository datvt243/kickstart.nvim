-- toggleterm.nvim — terminal nhỏ ở bottom, giống VSCode (terminal only)
if vim.g.vscode ~= nil then return end

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'akinsho/toggleterm.nvim' }

require('toggleterm').setup {
  size = 15,
  direction = 'horizontal',
  shade_terminals = true,
}

-- ### TERMINAL KEYMAPS
-- <leader>tt → toggle terminal (normal + terminal mode)
-- Bật/tắt terminal ở bottom từ normal mode
vim.keymap.set('n', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
-- Bật/tắt terminal ở bottom từ bên trong terminal mode (không cần thoát về normal trước)
vim.keymap.set('t', '<leader>tt', '<cmd>ToggleTerm<CR>', { desc = '[T]oggle [T]erminal' })
