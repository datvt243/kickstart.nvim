-- winbar (built-in Neovim, không phải plugin): hiện tên buffer ở đầu MỖI cửa sổ/split.
-- Khác bufferline.lua (tabline global — chỉ 1 dòng cho toàn bộ Neovim, không tách được
-- theo từng split): winbar là window-local nên mở 2 split thì mỗi split tự có 1 dòng
-- tên file riêng, đúng nhu cầu "mở 2 editor thì mỗi editor 1 tab".
-- https://neovim.io/doc/user/options.html#'winbar'
if vim.g.vscode ~= nil then return end

-- Whitelist thay vì blacklist filetype: chỉ bật winbar cho buffer file thật (buftype
-- rỗng), các loại window khác (sidebar, terminal, quickfix, help, prompt...) đều có
-- buftype khác rỗng nên tự động không hiện, không cần liệt kê từng filetype.
-- %t = tên buffer (tail, không kèm đường dẫn) — %f sẽ ra cả đường dẫn dài.
vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
  group = vim.api.nvim_create_augroup('winbar-editor-only', { clear = true }),
  callback = function(event)
    vim.wo.winbar = vim.bo[event.buf].buftype == '' and '%#WinBar# %t %m' or ''
  end,
})
