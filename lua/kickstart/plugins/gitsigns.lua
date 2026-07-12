-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.
--
vim.pack.add { 'https://github.com/lewis6991/gitsigns.nvim' }

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local ok, wk = pcall(require, 'which-key')
    if ok then
      wk.add {
        { '<leader>gh', buffer = bufnr, group = 'Git [H]unk' },
        { '<leader>gh', buffer = bufnr, group = 'Git [H]unk', mode = 'v' },
        { '<leader>tb', buffer = bufnr, desc = 'Toggle blame line' },
        { '<leader>tw', buffer = bufnr, desc = 'Toggle word diff' },
        { ']c', buffer = bufnr, desc = 'Next git hunk' },
        { '[c', buffer = bufnr, desc = 'Prev git hunk' },
        { 'ih', buffer = bufnr, desc = 'Git hunk (text object)', mode = { 'o', 'x' } },
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
        vim.cmd.normal {
          ']c',
          bang = true,
        }
      else
        gitsigns.nav_hunk 'next'
      end
    end, {
      desc = 'Jump to next git [c]hange',
    })

    -- Nhảy đến git hunk trước đó trong file
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal {
          '[c',
          bang = true,
        }
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
      desc = 'git [s]tage hunk',
    })
    -- Reset chỉ vùng được chọn trong visual mode về trạng thái index
    map('v', '<leader>ghr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, {
      desc = 'git [r]eset hunk',
    })
    -- normal mode
    -- Stage hunk tại cursor (thêm vào staging area)
    map('n', '<leader>ghs', gitsigns.stage_hunk, {
      desc = 'git [s]tage hunk',
    })
    -- Reset hunk tại cursor về trạng thái index (discard thay đổi)
    map('n', '<leader>ghr', gitsigns.reset_hunk, {
      desc = 'git [r]eset hunk',
    })
    -- Stage toàn bộ file hiện tại (git add <file>)
    map('n', '<leader>ghS', gitsigns.stage_buffer, {
      desc = 'git [S]tage buffer',
    })
    -- Reset toàn bộ file về trạng thái index (discard tất cả thay đổi chưa stage)
    map('n', '<leader>ghR', gitsigns.reset_buffer, {
      desc = 'git [R]eset buffer',
    })
    -- Xem preview hunk trong popup (diff format)
    map('n', '<leader>ghp', gitsigns.preview_hunk, {
      desc = 'git [p]review hunk',
    })
    -- Xem preview hunk inline trong buffer (thêm dòng hiển thị diff ngay tại chỗ)
    map('n', '<leader>ghi', gitsigns.preview_hunk_inline, {
      desc = 'git preview hunk [i]nline',
    })
    -- Xem git blame đầy đủ cho dòng hiện tại (author, date, commit message)
    map('n', '<leader>ghb', function()
      gitsigns.blame_line {
        full = true,
      }
    end, {
      desc = 'git [b]lame line',
    })
    -- Diff file hiện tại so với staging area (index)
    map('n', '<leader>ghd', gitsigns.diffthis, {
      desc = 'git [d]iff against index',
    })
    -- Diff file hiện tại so với commit trước (HEAD~1)
    map('n', '<leader>ghD', function() gitsigns.diffthis '@' end, {
      desc = 'git [D]iff against last commit',
    })
    -- Đưa tất cả hunks trong repo vào quickfix list để navigate
    map('n', '<leader>ghQ', function() gitsigns.setqflist 'all' end, {
      desc = 'git hunk [Q]uickfix list (all files in repo)',
    })
    -- Đưa hunks trong file hiện tại vào quickfix list
    map('n', '<leader>ghq', gitsigns.setqflist, {
      desc = 'git hunk [q]uickfix list (all changes in this file)',
    })
    -- Toggles
    -- Bật/tắt hiển thị git blame inline trên dòng hiện tại
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, {
      desc = '[T]oggle git show [b]lame line',
    })
    -- Bật/tắt word-level diff highlight (làm nổi bật từng từ thay đổi)
    map('n', '<leader>tw', gitsigns.toggle_word_diff, {
      desc = '[T]oggle git intra-line [w]ord diff',
    })

    -- Text object
    -- Chọn hunk như text object: dùng với operator (dih xóa hunk, yih yank hunk...)
    map({ 'o', 'x' }, 'ih', gitsigns.select_hunk)
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
vim.keymap.set('n', '<leader>gs', function() git_float({ 'git', 'status' }, 'Git Status') end, { desc = '[G]it [S]tatus' })

-- Stage tất cả thay đổi trong working tree (git add -A)
vim.keymap.set('n', '<leader>ga', function() git_run({ 'git', 'add', '-A' }, 'git add -A') end, { desc = '[G]it [A]dd all' })

-- Nhập commit message qua prompt rồi commit
vim.keymap.set('n', '<leader>gc', function()
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if msg and msg ~= '' then git_run({ 'git', 'commit', '-m', msg }, 'git commit') end
  end)
end, { desc = '[G]it [C]ommit' })

-- Push branch hiện tại lên remote origin
vim.keymap.set('n', '<leader>gps', function() git_run({ 'git', 'push' }, 'git push') end, { desc = '[G]it [P]u[s]h' })

-- Pull từ remote về branch hiện tại (git pull)
vim.keymap.set('n', '<leader>gpl', function() git_run({ 'git', 'pull' }, 'git pull') end, { desc = '[G]it [P]u[l]l' })

local ok, wk = pcall(require, 'which-key')
if ok then wk.add { { '<leader>g', group = '[G]it' } } end
