-- neoscroll.nvim: smooth scrolling (terminal only)
-- https://github.com/karb94/neoscroll.nvim
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'karb94/neoscroll.nvim' }

-- ### NEOSCROLL — smooth scroll cho Ctrl-u/d/b/f/y/e và zt/zz/zb (mapping mặc định)
-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  hide_cursor = true,
  stop_eof = true,
  respect_scrolloff = false,
  cursor_scrolls_alone = true,
  easing = 'linear',
}

require('neoscroll').setup(config)
