-- Kiểm tra Neovim đang chạy trong VSCode (do vscode-neovim extension set)
local is_vscode = vim.g.vscode ~= nil

-- ============================================================
-- SECTION 1: FOUNDATION — Cài đặt cơ bản
-- ============================================================
do
  if vim.loader and vim.loader.enable then
    vim.loader.enable()
  end

  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = true -- đổi thành true nếu dùng Nerd Font

  -- True color chỉ cần ở terminal; VSCode tự quản lý màu
  if not is_vscode then
    vim.o.termguicolors = true
  end

  -- [[ Options ]]
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.mouse = 'a'
  vim.o.showmode = false
  vim.schedule(function()
    vim.o.clipboard = 'unnamedplus'
  end)
  vim.o.breakindent = true
  vim.o.undofile = true -- lưu lịch sử undo sau khi đóng file
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.signcolumn = 'yes'
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.list = true
  vim.opt.listchars = {
    tab = '» ',
    trail = '·',
    nbsp = '␣'
  }
  vim.o.inccommand = 'split' -- xem trước kết quả :s/... theo thời gian thực
  vim.o.cursorline = true
  vim.o.scrolloff = 10
  vim.o.confirm = true

  vim.o.autoread = true
  vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
    command = 'checktime',
  })

  -- Xóa highlight tìm kiếm khi bấm Esc ở normal mode
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Cấu hình diagnostic (lỗi/warning từ LSP)
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = 'rounded',
      source = 'if_many'
    },
    underline = {
      severity = {
        min = vim.diagnostic.severity.WARN
      }
    },
    virtual_text = true,
    virtual_lines = false,
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false
        }
      end
    }
  }

  -- Mở danh sách lỗi/warning từ LSP vào location list để navigate
  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, {
    desc = 'Mở danh sách diagnostic'
  })

  -- ### KEYMAPS CHUNG (terminal + VSCode)

  -- Di chuyển theo visual line — j/k không bỏ qua wrapped text
  -- Khi có count (5j, 10k) thì vẫn dùng j/k thật để nhảy đúng số dòng
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", {
    expr = true,
    silent = true
  })
  -- Tương tự j nhưng đi lên
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", {
    expr = true,
    silent = true
  })

  -- Nhảy paragraph và căn giữa màn hình
  vim.keymap.set('n', '}', '}zz', {
    desc = 'Paragraph kế (center)'
  })
  -- Nhảy về paragraph trước và căn giữa màn hình
  vim.keymap.set('n', '{', '{zz', {
    desc = 'Paragraph trước (center)'
  })

  -- Ngắt dòng tại cursor, không vào insert mode
  vim.keymap.set('n', 'B', 'i<CR><Esc>', {
    desc = 'Ngắt dòng tại cursor'
  })

  -- ### BUFFER
  -- Chuyển sang buffer trước (theo thứ tự buffer list)
  vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', {
    desc = 'Buffer trước'
  })
  -- Chuyển sang buffer tiếp theo
  vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', {
    desc = 'Buffer tiếp'
  })
  -- Đóng buffer hiện tại (không thoát Neovim)
  vim.keymap.set('n', '<leader>bq', '<cmd>bdelete<CR>', {
    desc = '[B]uffer đóng'
  })
  -- Tạo buffer mới trống (chưa lưu file)
  vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', {
    desc = '[B]uffer mới'
  })
  -- Yank toàn bộ nội dung file vào clipboard hệ thống
  vim.keymap.set('n', '<leader>by', '<cmd>%y+<CR>', {
    desc = '[B]uffer yank toàn bộ'
  })

  -- Lưu file từ cả insert lẫn normal mode
  vim.keymap.set('i', '<C-s>', '<cmd>w<CR><Esc>', {
    desc = 'Lưu file'
  })
  -- Lưu file từ normal mode
  vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', {
    desc = 'Lưu file'
  })

  -- ### INDENT / MOVE LINES

  -- Visual mode: giữ nguyên selection sau khi indent
  vim.keymap.set('v', '<tab>', '>gv', {
    desc = 'Tăng indent'
  })
  -- Giảm indent và giữ nguyên selection
  vim.keymap.set('v', '<S-tab>', '<gv', {
    desc = 'Giảm indent'
  })

  -- Di chuyển dòng trong visual mode (C-j/k không conflict vì window nav ở normal mode)
  vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", {
    silent = true,
    desc = 'Dời dòng xuống'
  })
  -- Dời selection lên (re-indent tự động sau khi move)
  vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", {
    silent = true,
    desc = 'Dời dòng lên'
  })

  -- Normal mode dùng Alt để không conflict với C-j/k (window nav ở terminal)
  vim.keymap.set('n', '<A-j>', '<cmd>m .+1<CR>==', {
    desc = 'Dời dòng xuống'
  })
  -- Dời dòng hiện tại lên và re-indent
  vim.keymap.set('n', '<A-k>', '<cmd>m .-2<CR>==', {
    desc = 'Dời dòng lên'
  })

  -- ### SPLITS
  -- Mở split dọc (cửa sổ mới bên phải)
  vim.keymap.set('n', '<leader>v', '<cmd>vsplit<CR>', {
    desc = 'Split dọc'
  })
  -- Mở split ngang (cửa sổ mới bên dưới)
  vim.keymap.set('n', '<leader>S', '<cmd>split<CR>', {
    desc = 'Split ngang'
  })

  -- ### PASTE OVER TEXT OBJECTS
  -- Thay thế nội dung bên trong/xung quanh text object bằng clipboard
  -- Ví dụ: <leader>piq → paste vào trong cặp nháy gần nhất
  -- Paste vào trong cặp quote gần nhất (thay nội dung, giữ nguyên quote)
  vim.keymap.set('n', '<leader>piq', 'viqp', {
    desc = 'Paste inside quote'
  })
  -- Paste đè toàn bộ cặp quote gần nhất (kể cả dấu nháy)
  vim.keymap.set('n', '<leader>paq', 'vaqp', {
    desc = 'Paste around quote'
  })
  -- Paste vào trong cặp {} gần nhất (giữ nguyên dấu ngoặc)
  vim.keymap.set('n', '<leader>piB', 'viB"_dP', {
    desc = 'Paste inside {}'
  })
  -- Paste đè toàn bộ cặp {} gần nhất (kể cả dấu ngoặc)
  vim.keymap.set('n', '<leader>paB', 'vaB"_dP', {
    desc = 'Paste around {}'
  })
  -- Paste vào trong cặp () gần nhất
  vim.keymap.set('n', '<leader>pib', 'vib"_dP', {
    desc = 'Paste inside ()'
  })
  -- Paste đè toàn bộ cặp () gần nhất
  vim.keymap.set('n', '<leader>pab', 'vab"_dP', {
    desc = 'Paste around ()'
  })
  -- Paste vào trong HTML/XML tag gần nhất (giữ nguyên tag)
  vim.keymap.set('n', '<leader>pit', 'vit"_dP', {
    desc = 'Paste inside tag'
  })
  -- Paste đè toàn bộ HTML/XML tag gần nhất (kể cả opening/closing tag)
  vim.keymap.set('n', '<leader>pat', 'vat"_dP', {
    desc = 'Paste around tag'
  })

  -- Misc
  -- Xóa highlight kết quả tìm kiếm thủ công (khi Esc bị override ở nơi khác)
  vim.keymap.set('n', '<leader>n', '<cmd>nohlsearch<CR>', {
    desc = 'Tắt highlight tìm kiếm'
  })
  -- Xem nội dung tất cả registers (clipboard, yank history, macro...)
  vim.keymap.set('n', '<leader>y', '<cmd>registers<CR>', {
    desc = 'Xem registers'
  })

  -- Cập nhật plugin: :PackUpdate (chỉ terminal)
  if not is_vscode then
    vim.api.nvim_create_user_command('PackUpdate', function()
      local ok, err = pcall(function()
        vim.pack.update(nil, {
          offline = false
        })
      end)
      if not ok then
        vim.notify(('PackUpdate thất bại: %s'):format(err), vim.log.levels.ERROR)
      end
    end, {
      desc = 'Cập nhật plugin qua vim.pack'
    })
  end

  -- Thoát terminal mode bằng Esc Esc (mặc định phải dùng C-\ C-n)
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', {
    desc = 'Thoát terminal mode'
  })

  -- File explorer: VSCode dùng sidebar (Section 9); terminal dùng neo-tree (keymap đặt trong neo-tree.lua)

  -- ### WINDOW NAVIGATION (chỉ terminal)
  -- VSCode: C-j/k dùng để move lines; focus pane dùng <leader>w ở Section 9
  if not is_vscode then
    -- Nhảy sang cửa sổ bên trái
    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', {
      desc = 'Focus cửa sổ trái'
    })
    -- Nhảy sang cửa sổ bên phải
    vim.keymap.set('n', '<C-l>', '<C-w><C-l>', {
      desc = 'Focus cửa sổ phải'
    })
    -- Nhảy xuống cửa sổ bên dưới
    vim.keymap.set('n', '<C-j>', '<C-w><C-j>', {
      desc = 'Focus cửa sổ dưới'
    })
    -- Nhảy lên cửa sổ bên trên
    vim.keymap.set('n', '<C-k>', '<C-w><C-k>', {
      desc = 'Focus cửa sổ trên'
    })
  end

  -- Highlight vùng text vừa yank
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight khi yank',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', {
      clear = true
    }),
    callback = function()
      vim.hl.on_yank()
    end
  })
end

-- ============================================================
-- SECTION 2: PLUGIN MANAGER — vim.pack (chỉ terminal)
-- ============================================================
if not is_vscode then
  do
    -- vim.pack: plugin manager tích hợp sẵn trong Neovim
    -- Cập nhật:        :lua vim.pack.update()
    -- Xem trạng thái:  :lua vim.pack.update(nil, { offline = true })
    -- Cập nhật nhanh:  :PackUpdate

    local function run_build(name, cmd, cwd)
      local result = vim.system(cmd, {
        cwd = cwd
      }):wait()
      if result.code ~= 0 then
        local stderr = result.stderr or ''
        local stdout = result.stdout or ''
        local output = stderr ~= '' and stderr or stdout
        if output == '' then
          output = 'Không có output.'
        end
        vim.notify(('Build thất bại cho %s:\n%s'):format(name, output), vim.log.levels.ERROR)
      end
    end

    -- Chạy build step sau khi plugin được cài/cập nhật
    vim.api.nvim_create_autocmd('PackChanged', {
      callback = function(ev)
        local name = ev.data.spec.name
        local kind = ev.data.kind
        if kind ~= 'install' and kind ~= 'update' then
          return
        end
        if not name then
          return
        end

        if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
          run_build(name, {'make'}, ev.data.path)
          return
        end

        if name == 'LuaSnip' then
          if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
            run_build(name, {'make', 'install_jsregexp'}, ev.data.path)
          end
          return
        end

        if name == 'nvim-treesitter' then
          if not ev.data.active then
            vim.cmd.packadd 'nvim-treesitter'
          end
          vim.cmd 'TSUpdate'
          return
        end
      end
    })
  end
end

-- Load tất cả plugin từ lua/custom/plugins/
require 'custom.plugins'

-- ============================================================
-- SECTION 10: PLUGINS TÙY CHỌN
-- Bỏ comment để bật; khởi động lại Neovim sau khi thay đổi
-- ============================================================
do
  require 'kickstart.plugins.autopairs' -- tự đóng ngoặc
  -- require 'kickstart.plugins.indent_line'      -- indent guides
  -- require 'kickstart.plugins.debug'         -- DAP debugger
  -- require 'kickstart.plugins.lint'          -- linter
  require 'kickstart.plugins.neo-tree' -- file explorer nâng cao
  require 'kickstart.plugins.gitsigns' -- git keymaps đầy đủ
end

-- vim: ts=2 sts=2 sw=2 et
