-- tokyonight.nvim: colorscheme (terminal only)
-- Đổi theme: đổi `style` bên dưới → storm / moon / night / day, rồi đổi tên variant
-- tương ứng ở vim.cmd.colorscheme cuối file (vd: 'tokyonight-storm')
-- https://github.com/folke/tokyonight.nvim
if vim.g.vscode ~= nil then return end

-- Chỉ 1 trong 2 file (tokyonight.lua / catppuccin.lua) nên để active = true tại 1 thời điểm
local active = false

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/tokyonight.nvim' }

---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
  style = 'night', -- storm | moon | night | day
  light_style = 'day', -- style dùng khi background = light
  transparent = false, -- true để tắt set background, terminal trong suốt xuyên qua
  terminal_colors = true, -- áp màu theme cho :terminal
  styles = {
    comments = { italic = false },
    keywords = { italic = true },
    functions = {},
    variables = {},
    sidebars = 'dark', -- style cho các filetype trong `sidebars` bên dưới
    floats = 'dark', -- style cho floating windows
  },
  sidebars = { 'qf', 'help', 'neo-tree' }, -- filetype có nền tối hơn background chính
  day_brightness = 0.3, -- độ sáng màu khi dùng style "day"
  dim_inactive = false, -- true để làm tối window không active
  lualine_bold = false, -- true để bold section header nếu dùng lualine
  cache = true, -- cache highlight groups để load nhanh hơn
  on_colors = function(_) end,
  on_highlights = function(_, _) end,
}

if active then vim.cmd.colorscheme 'tokyonight-night' end
