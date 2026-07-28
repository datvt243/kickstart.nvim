-- nvim-ufo: fold code theo scope bằng treesitter (hàm/if/loop...), foldtext gọn + xem trước fold (terminal only)
-- Cần promise-async làm dependency. https://github.com/kevinhwang91/nvim-ufo
-- Keymap nổi bật: zR/zM mở/đóng hết, zr/zm mở/đóng theo cấp, zK xem trước fold — marker ### UFO KEYMAPS
if vim.g.vscode ~= nil then return end

vim.pack.add {
  gh 'kevinhwang91/promise-async',
  gh 'kevinhwang91/nvim-ufo',
}

-- ufo cần foldlevel cao + foldenable để file mở ra là bung sẵn mọi fold (đóng chủ động bằng phím)
vim.o.foldcolumn = '1' -- cột nhỏ bên trái hiện dấu fold
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true

-- foldtext: thay dòng "+-- N lines" mặc định bằng dòng đầu của scope + số dòng đã fold (căn phải),
-- vẫn giữ highlight cú pháp của dòng đầu (virt_text do ufo truyền vào).
local function fold_virt_text(virt_text, lnum, end_lnum, width, truncate)
  local new_virt_text = {}
  local suffix = (' ↙ %d dòng'):format(end_lnum - lnum)
  local suf_width = vim.fn.strdisplaywidth(suffix)
  local target_width = width - suf_width
  local cur_width = 0
  for _, chunk in ipairs(virt_text) do
    local chunk_text = chunk[1]
    local chunk_width = vim.fn.strdisplaywidth(chunk_text)
    if target_width > cur_width + chunk_width then
      table.insert(new_virt_text, chunk)
    else
      chunk_text = truncate(chunk_text, target_width - cur_width)
      table.insert(new_virt_text, { chunk_text, chunk[2] })
      chunk_width = vim.fn.strdisplaywidth(chunk_text)
      if cur_width + chunk_width < target_width then suffix = suffix .. (' '):rep(target_width - cur_width - chunk_width) end
      break
    end
    cur_width = cur_width + chunk_width
  end
  table.insert(new_virt_text, { suffix, 'MoreMsg' })
  return new_virt_text
end

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  -- Fold theo treesitter (đúng scope code); fallback 'indent' nếu buffer chưa có parser
  provider_selector = function(_, _, _) return { 'treesitter', 'indent' } end,
  fold_virt_text_handler = fold_virt_text,
}

local ufo = require 'ufo'
ufo.setup(config)

-- ### UFO KEYMAPS

-- Mở tất cả fold trong file
vim.keymap.set('n', 'zR', ufo.openAllFolds, {
  desc = 'Ufo: mở tất cả fold',
})

-- Đóng tất cả fold trong file
vim.keymap.set('n', 'zM', ufo.closeAllFolds, {
  desc = 'Ufo: đóng tất cả fold',
})

-- Mở fold theo từng cấp (nhận count, vd 2zr)
vim.keymap.set('n', 'zr', ufo.openFoldsExceptKinds, {
  desc = 'Ufo: mở fold theo cấp',
})

-- Đóng fold theo từng cấp
vim.keymap.set('n', 'zm', ufo.closeFoldsWith, {
  desc = 'Ufo: đóng fold theo cấp',
})

-- Xem trước nội dung scope đang fold dưới con trỏ (không cần mở); không có fold thì fallback về hover
vim.keymap.set('n', 'zK', function()
  local winid = ufo.peekFoldedLinesUnderCursor()
  if not winid then vim.lsp.buf.hover() end
end, {
  desc = 'Ufo: xem trước fold',
})
