-- Cài đặt option cơ bản của Neovim (vim.g / vim.o / vim.opt)
local is_vscode = vim.g.vscode ~= nil

-- Leader key dùng cho hầu hết custom keymap (<leader>xxx)
vim.g.mapleader = ' '

-- Local leader key, dùng cho keymap riêng theo filetype/plugin
vim.g.maplocalleader = ' '

-- Cho phép plugin dùng icon Nerd Font (đổi thành false nếu terminal không có Nerd Font)
vim.g.have_nerd_font = true

-- True color chỉ cần ở terminal; VSCode tự quản lý màu nên không set ở đó
if not is_vscode then vim.o.termguicolors = true end

-- Hiện phím đang gõ dở (vd: đang gõ "2d" chờ motion) ngay trong statusline (lualine)
-- thay vì ở dòng cmdline cuối cùng — giống statusbar của VSCode. Cần lualine có
-- component '%S' tương ứng (xem custom/plugins/ui/lualine.lua)
if not is_vscode then vim.o.showcmdloc = 'statusline' end

-- [[ Options ]]

-- Hiện số dòng bên trái
vim.o.number = true

-- Số dòng hiển thị dạng tương đối (trừ dòng hiện tại) — dễ dùng lệnh có count (5j, 3dd...)
vim.o.relativenumber = true

-- Cho phép dùng chuột ở mọi mode
vim.o.mouse = 'a'

-- Ẩn dòng trạng thái mode (-- INSERT --...) vì đã có lualine hiển thị
vim.o.showmode = false

-- Dùng clipboard hệ thống cho yank/paste; đặt trong vim.schedule để không làm chậm startup
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Dòng bị wrap sẽ thụt đầu dòng theo dòng gốc, không dính sát lề trái
vim.o.breakindent = true

-- Lưu lịch sử undo ra file, undo được cả sau khi đóng và mở lại file
vim.o.undofile = true

-- Tìm kiếm không phân biệt hoa/thường
vim.o.ignorecase = true

-- Trừ khi pattern tìm kiếm có chữ hoa thì mới phân biệt hoa/thường (kết hợp với ignorecase)
vim.o.smartcase = true

-- Luôn hiện cột dấu hiệu (diagnostic, git sign...) để tránh giật layout khi dấu hiệu xuất hiện/biến mất
vim.o.signcolumn = 'yes'

-- Thời gian (ms) không gõ gì thì trigger CursorHold/autosave swap — giảm để phản hồi nhanh hơn
vim.o.updatetime = 250

-- Thời gian (ms) chờ giữa các phím trong 1 tổ hợp (leader, which-key...) trước khi timeout
vim.o.timeoutlen = 300

-- Split dọc mới mở bên phải (thay vì bên trái mặc định)
vim.o.splitright = true

-- Split ngang mới mở bên dưới (thay vì bên trên mặc định)
vim.o.splitbelow = true

-- Hiện ký tự ẩn (tab, trailing space...) theo listchars bên dưới
vim.o.list = true

-- Ký tự tượng trưng cho tab, trailing space, non-breaking space khi list = true
vim.opt.listchars = {
  tab = '» ',
  trail = '·',
  nbsp = '␣',
}

-- Xem trước kết quả :s/... (substitute) ngay trong 1 split, chưa cần Enter
vim.o.inccommand = 'split'

-- Highlight dòng chứa con trỏ, dễ nhận biết vị trí đang đứng
vim.o.cursorline = true

-- Giữ tối thiểu 10 dòng phía trên/dưới con trỏ khi cuộn, tránh con trỏ dính sát mép màn hình
vim.o.scrolloff = 10

-- Hỏi xác nhận thay vì báo lỗi khi thực hiện thao tác có thể mất dữ liệu (:q khi chưa save...)
vim.o.confirm = true

-- Tự động đọc lại file khi bị thay đổi từ bên ngoài Neovim (miễn là buffer chưa sửa gì)
vim.o.autoread = true

-- Trigger check file có bị thay đổi từ ngoài hay không ở các thời điểm hay quay lại Neovim.
-- Bỏ qua buffer terminal (Claude Code, toggleterm...) và defer bằng vim.schedule: checktime
-- chạy đồng bộ ngay trên FocusGained có thể "nuốt" phím đầu của bộ gõ tiếng Việt (EVKey/Unikey)
-- khi focus lại terminal — nên không cho nó chen vào đường phím ở buffer terminal.
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  group = vim.api.nvim_create_augroup('options-checktime', {
    clear = true,
  }),
  callback = function()
    if vim.bo.buftype == 'terminal' then return end
    vim.schedule(function()
      if vim.bo.buftype ~= 'terminal' then vim.cmd 'checktime' end
    end)
  end,
})

-- Tắt swap file (.swp) — không bị hỏi dialog "Found a swap file" khi mở lại file
-- đang mở ở session khác. Đánh đổi: mất khả năng :recover khi crash, nên bù lại
-- bằng autosave khi rời Neovim/mất focus (xem autocmd FocusLost/BufLeave bên dưới).
vim.o.swapfile = false

-- Tự lưu file khi Neovim mất focus (đổi sang app khác) hoặc rời buffer đang sửa
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave' }, {
  group = vim.api.nvim_create_augroup('options-autosave', {
    clear = true,
  }),
  pattern = '*',
  command = 'silent! wa',
})
