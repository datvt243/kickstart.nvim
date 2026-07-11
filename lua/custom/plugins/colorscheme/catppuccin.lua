-- catppuccin.nvim: colorscheme (terminal only)
-- Đổi theme: đổi `flavour` bên dưới → latte / frappe / macchiato / mocha
-- https://github.com/catppuccin/nvim
if vim.g.vscode ~= nil then return end

-- Chỉ 1 trong 2 file (tokyonight.lua / catppuccin.lua) nên để active = true tại 1 thời điểm
local active = true

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'catppuccin/nvim' }

require('catppuccin').setup {
  flavour = 'mocha', -- latte | frappe | macchiato | mocha
  background = { light = 'latte', dark = 'mocha' }, -- flavour theo 'background' của vim.o
  transparent_background = false,
  show_end_of_buffer = false,
  term_colors = true, -- áp màu theme cho :terminal
  dim_inactive = { enabled = false, shade = 'dark', percentage = 0.15 },
  no_italic = false,
  no_bold = false,
  no_underline = false,
  styles = {
    comments = { 'italic' },
    conditionals = { 'italic' },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
  },
  color_overrides = {},
  custom_highlights = {},
  default_integrations = true,
  integrations = {
    treesitter = true,
    native_lsp = { enabled = true },
    telescope = { enabled = true },
    gitsigns = true,
    neotree = true,
    mini = { enabled = true },
    which_key = true,
    noice = true,
    notify = true,
    blink_cmp = true,
  },
}

if active then vim.cmd.colorscheme 'catppuccin' end
