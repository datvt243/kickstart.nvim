-- which-key: hiển thị gợi ý keymap khi gõ leader (terminal only)
-- https://github.com/folke/which-key.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/which-key.nvim' }
-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  delay = 0, -- tăng tạm từ 0 → 500ms để gõ nhanh gg/ge/gv... không bị popup nhấp nháy giữa chừng
  plugins = {
    spelling = true,
    presets = {},
  },
  show_help = false,
  icons = {
    mappings = vim.g.have_nerd_font,
  },
  spec = {
    {
      '<leader>s',
      group = '[S]earch',
      mode = { 'n', 'v' },
    },
    {
      '<leader>t',
      group = '[T]oggle',
    },
    -- {
    --   '<leader>gh',
    --   group = 'Git [H]unk',
    --   mode = { 'n', 'v' },
    -- },
    {
      '<leader>q',
      group = '[Q]uick Motions',
    },
    {
      '<leader>x',
      group = 'Trouble (diagnostics/quickfix)',
    },
    {
      '<leader>b',
      group = '[B]uffers',
    },
    {
      '<leader>c',
      group = '[C]laude Code',
    },
    {
      '<leader>p',
      group = '[P]aste',
    },
    {
      'gr',
      group = 'LSP Actions',
      mode = { 'n' },
    },
  },
}

require('which-key').setup(config)
-- LƯU Ý: đây là nơi DUY NHẤT gọi require('which-key').setup() — gọi setup() lần thứ 2
-- ở file khác sẽ đè mất spec (group labels) của lần gọi đầu, gây lỗi which-key hiện
-- "N keymaps" thay vì tên group đã đặt.
