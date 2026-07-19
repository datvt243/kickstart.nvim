-- Adds git related signs to the gutter, as well as utilities for managing changes
-- Đây là NƠI DUY NHẤT setup gitsigns (base config + keymaps); init.lua chỉ require file này.
--
vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  -- Hiện git blame inline (author + thời gian + commit) trên dòng hiện tại ngay
  -- khi mở file. true = bật sẵn, false = tắt. Vẫn bật/tắt runtime bằng <leader>tb.
  current_line_blame = true,

  -- Tuỳ chỉnh cách hiển thị blame inline (chỉ có tác dụng khi current_line_blame = true)
  current_line_blame_opts = {
    delay = 1000, -- ms chờ sau khi dừng cursor mới hiện blame (mặc định gitsigns: 1000)
    virt_text_pos = 'eol', -- vị trí text ảo: 'eol' (cuối dòng) | 'overlay' | 'right_align'
  },

  -- Highlight từng từ thay đổi trong hunk (word-level diff) thay vì cả dòng.
  -- true = bật sẵn khi mở file. Vẫn bật/tắt runtime bằng <leader>tw.
  word_diff = true,
}

require('gitsigns').setup {
  current_line_blame = config.current_line_blame,
  current_line_blame_opts = config.current_line_blame_opts,
  word_diff = config.word_diff,

  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local ok, wk = pcall(require, 'which-key')
    if ok then
      -- Chỉ đăng ký GROUP label cho which-key (không suy ra được từ keymap lẻ).
      -- Các keymap <leader>tb/<leader>tw/]c/[c/ih không cần khai báo desc ở đây nữa:
      -- which-key tự đọc desc từ chính vim.keymap.set() bên dưới.
      wk.add {
        -- Normal 
        { '<leader>gh', buffer = bufnr, group = 'Git [H]unk' },
        { '<leader>gp', buffer = bufnr, group = 'Git Push/Pull' },

        -- Visual
        { '<leader>gh', buffer = bufnr, group = 'Git [H]unk', mode = 'v' },
      }
    end

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    -- Nhảy đến git hunk tiếp theo trong file (bỏ qua nếu đang trong diff view)
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true, }
      else
        gitsigns.nav_hunk 'next'
      end
    end, {
      desc = 'Jump to next git [c]hange',
    })

    -- Nhảy đến git hunk trước đó trong file
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true, }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, {
      desc = 'Jump to previous git [c]hange',
    })

  -- Actions
    -- visual mode
    -- Stage chỉ vùng được chọn trong visual mode (không phải toàn bộ hunk)
    map('v', '<leader>ghs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, {
      desc = 'Git [s]tage Hunk',
    })
    -- Reset chỉ vùng được chọn trong visual mode về trạng thái index
    map('v', '<leader>ghr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, {
      desc = 'Git [r]eset Hunk',
    })

    -- normal mode
    -- Stage hunk tại cursor (thêm vào staging area)
    map('n', '<leader>ghs', gitsigns.stage_hunk, {
      desc = 'Git [s]tage Hunk',
    })
    -- Reset hunk tại cursor về trạng thái index (discard thay đổi)
    map('n', '<leader>ghr', gitsigns.reset_hunk, {
      desc = 'git [r]eset Hunk',
    })
    -- Stage toàn bộ file hiện tại (git add <file>)
    map('n', '<leader>ghS', gitsigns.stage_buffer, {
      desc = 'Git [S]tage buffer',
    })
    -- Reset toàn bộ file về trạng thái index (discard tất cả thay đổi chưa stage)
    map('n', '<leader>ghR', gitsigns.reset_buffer, {
      desc = 'Git [R]eset buffer',
    })
    -- Xem preview hunk trong popup (diff format)
    map('n', '<leader>ghp', gitsigns.preview_hunk, {
      desc = 'Git [p]review hunk',
    })
    -- Xem preview hunk inline trong buffer (thêm dòng hiển thị diff ngay tại chỗ)
    map('n', '<leader>ghi', gitsigns.preview_hunk_inline, {
      desc = 'Git preview hunk [i]nline',
    })
    -- Diff file hiện tại so với staging area (index)
    map('n', '<leader>ghd', gitsigns.diffthis, {
      desc = 'Git [d]iff against index',
    })
    -- Diff file hiện tại so với commit trước (HEAD~1)
    map('n', '<leader>ghD', function() gitsigns.diffthis '@' end, {
      desc = 'Git [D]iff against last commit',
    })
    -- Đưa tất cả hunks trong repo vào quickfix list để navigate
    map('n', '<leader>ghQ', function() gitsigns.setqflist 'all' end, {
      desc = 'Git hunk [Q]uickfix list (all files in repo)',
    })
    -- Đưa hunks trong file hiện tại vào quickfix list
    map('n', '<leader>ghq', gitsigns.setqflist, {
      desc = 'Git hunk [q]uickfix list (all changes in this file)',
    })

    -- Text object
    -- Chọn hunk như text object: dùng với operator (dih xóa hunk, yih yank hunk...)
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, { desc = 'Git hunk (text object)' })
  end,
}

-- ### GIT COMMANDS (terminal)
local function git_float(args, title)
  local result = vim.fn.system(args)
  local lines = vim.split(result, '\n', { trimempty = true })
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = 'wipe'
  local width = math.min(80, vim.o.columns - 4)
  local height = math.min(#lines + 1, vim.o.lines - 6)
  vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = 'minimal',
    border = 'rounded',
    title = ' ' .. title .. ' ',
    title_pos = 'center',
  })
  vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = buf, silent = true })
  vim.keymap.set('n', '<Esc>', '<cmd>close<cr>', { buffer = buf, silent = true })
end

local function git_run(args, label)
  local result = vim.fn.system(args)
  local ok = vim.v.shell_error == 0
  vim.notify(ok and (label .. ' OK') or result:gsub('\n$', ''), ok and vim.log.levels.INFO or vim.log.levels.ERROR)
end

-- Hiển thị git status trong floating window (đóng bằng q hoặc Esc)
vim.keymap.set('n', '<leader>gs', function() git_float({ 'git', 'status' }, 'Git Status') end, { desc = 'Git [S]tatus' })

-- Stage tất cả thay đổi trong working tree (git add -A)
vim.keymap.set('n', '<leader>ga', function() git_run({ 'git', 'add', '-A' }, 'git add -A') end, { desc = 'Git [A]dd All' })

-- Nhập commit message qua prompt rồi commit
vim.keymap.set('n', '<leader>gc', function()
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if msg and msg ~= '' then git_run({ 'git', 'commit', '-m', msg }, 'git commit') end
  end)
end, { desc = 'Git [C]ommit' })

-- Reset hunk tại cursor về trạng thái index (discard thay đổi)
vim.keymap.set('n', '<leader>gr', function() require('gitsigns').reset_hunk() end, {
  desc = 'Git [r]evert change Hunk',
})

-- Push/Pull branch hiện tại lên remote origin
vim.keymap.set(
  'n',
  '<leader>gps',
  function() git_run({ 'git', 'push' }, 'git push') end,
  { desc = '[G]it [P]u[s]h' }
)
vim.keymap.set(
  'n',
  '<leader>gpl',
  function() git_run({ 'git', 'pull' }, 'git pull') end,
  { desc = '[G]it [P]u[l]l' }
)

local ok, wk = pcall(require, 'which-key')
if ok then wk.add { { '<leader>g', group = '[G]it' } } end
