-- nvim-autopairs: tự động đóng cặp ngoặc/quote khi gõ — (), [], {}, '', ""... (terminal only)
-- https://github.com/windwp/nvim-autopairs
if vim.g.vscode ~= nil then return end

vim.pack.add { 'https://github.com/windwp/nvim-autopairs' }
require('nvim-autopairs').setup {}
