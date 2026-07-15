-- flash.nvim: nhảy nhanh đến bất kỳ vị trí nào bằng s/S (chạy ở cả terminal lẫn VSCode)
-- Flash là Neovim plugin thuần: labels render qua extmarks, input qua Neovim channel
-- → không conflict với vscode-neovim (khác Jumpy vốn hook 'type' command của VSCode)
-- <leader>j → jump word (thay Jumpy trong VSCode)
-- s / S     → jump / treesitter (terminal, xem thêm trong block if not is_vscode)
--
local is_vscode = vim.g.vscode ~= nil
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup {
  modes = {
    search = { enabled = false }, -- không override / và ?
    char = { enabled = false }, -- không override f/t/F/T
  },
}
-- Flash jump đến bất kỳ vị trí trong file;
-- hoạt động cả ở VSCode vì dùng Neovim channel
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', function() require('flash').jump() end, { desc = 'Flash jump' })

if not is_vscode then
  -- ### FLASH.NVIM — terminal-only keymaps
  -- s{2 ký tự}   → nhảy đến vị trí khớp trong file (sneak)
  -- S            → chọn node treesitter xung quanh cursor
  -- r (operator) → remote flash, vd: yr{ab} để yank từ xa
  -- <leader>.    → fuzzy jump kiểu easymotion

  -- Sneak jump: gõ 2 ký tự để nhảy đến vị trí khớp (phong cách vim-sneak)
  vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, {
    desc = 'Flash jump',
  })

  -- Treesitter jump: highlight và chọn node syntax xung quanh cursor
  vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, {
    desc = 'Flash treesitter',
  })

  -- Remote operator: thực hiện operator (y/d/c...) tại vị trí flash rồi quay về cursor
  vim.keymap.set('o', 'r', function() require('flash').remote() end, {
    desc = 'Flash remote operator',
  })
end
