-- lualine.nvim: statusline (terminal only)
-- theme = 'auto' → tự nhận diện theo colorscheme đang active (tokyonight / catppuccin, xem colorscheme/)
-- https://github.com/nvim-lualine/lualine.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'nvim-lualine/lualine.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  options = {
    theme = 'auto',
    icons_enabled = vim.g.have_nerd_font,
    component_separators = '|',
    section_separators = '',
    globalstatus = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    -- '%S' là statusline item gốc của Vim, hiển thị phím đang gõ dở nhờ
    -- vim.o.showcmdloc = 'statusline' (xem lua/options.lua)
    lualine_x = { function() return '%S' end, 'filetype' },
    lualine_y = {},
    lualine_z = { 'location' }, -- mặc định đã là dạng line:col, không kèm %
  },
}

require('lualine').setup(config)
