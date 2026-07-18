-- diffview.nvim: panel liệt kê tất cả file đã thay đổi + diff trực quan, giống VSCode Source Control (terminal only)
-- https://github.com/sindrets/diffview.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'sindrets/diffview.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  -- Highlight thay đổi ở mức từng từ/ký tự trong dòng (không chỉ tô nguyên dòng) — giống diff VSCode
  enhanced_diff_hl = true,

  keymaps = {
    -- Diffview mặc định chỉ có 'q' để đóng từng panel riêng lẻ, không có phím đóng
    -- toàn bộ view. Thêm Esc ở cả 3 chỗ (buffer diff, file panel, file history panel)
    -- để đóng toàn bộ Diffview từ bất kỳ đâu bên trong nó — không đụng Esc global
    -- (nohlsearch, xem init.lua) vì các mapping này chỉ có hiệu lực bên trong Diffview.
    view = {
      { 'n', '<Esc>', '<cmd>DiffviewClose<CR>', { desc = 'Đóng Diffview' } },
    },
    file_panel = {
      { 'n', '<Esc>', '<cmd>DiffviewClose<CR>', { desc = 'Đóng Diffview' } },
    },
    file_history_panel = {
      { 'n', '<Esc>', '<cmd>DiffviewClose<CR>', { desc = 'Đóng Diffview' } },
    },
  },
}

require('diffview').setup(config)

-- ### DIFFVIEW KEYMAPS
-- Mở panel diffview: liệt kê tất cả file đã đổi (working tree), chọn file để xem diff
vim.keymap.set('n', '<leader>gv', '<cmd>DiffviewOpen<CR>', { desc = '[G]it diff[V]iew: mở panel file đã đổi' })

-- Đóng panel diffview
-- vim.keymap.set('n', '<leader>gV', '<cmd>DiffviewClose<CR>', { desc = '[G]it diff[V]iew: đóng panel' })

-- Xem lịch sử thay đổi (log + diff) của file hiện tại — giống Timeline của VSCode
vim.keymap.set('n', '<leader>gl', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it [L]og: lịch sử file hiện tại' })

-- Xem lịch sử thay đổi (log + diff) toàn bộ repo
vim.keymap.set('n', '<leader>gL', '<cmd>DiffviewFileHistory<CR>', { desc = '[G]it [L]og: lịch sử toàn repo' })
