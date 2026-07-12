-- indent-blankline.nvim (ibl): hiển thị indent guide, kể cả ở dòng trống (terminal only)
-- https://github.com/lukas-reineke/indent-blankline.nvim
if vim.g.vscode ~= nil then return end

vim.pack.add {
  'https://github.com/lukas-reineke/indent-blankline.nvim',
}
require('ibl').setup {}
