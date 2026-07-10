-- Adds git related signs to the gutter, as well as utilities for managing changes
-- NOTE: gitsigns is already included in init.lua but contains only the base
-- config. This will add also the recommended keymaps.
-- 
vim.pack.add {'https://github.com/lewis6991/gitsigns.nvim'}

require('gitsigns').setup {
  on_attach = function(bufnr)
    local gitsigns = require 'gitsigns'

    local ok, wk = pcall(require, 'which-key')
    if ok then
      wk.add({
        { '<leader>h',  buffer = bufnr, group = 'Git [H]unk' },
        { '<leader>h',  buffer = bufnr, group = 'Git [H]unk', mode = 'v' },
        { '<leader>tb', buffer = bufnr, desc = 'Toggle blame line' },
        { '<leader>tw', buffer = bufnr, desc = 'Toggle word diff' },
        { ']c',         buffer = bufnr, desc = 'Next git hunk' },
        { '[c',         buffer = bufnr, desc = 'Prev git hunk' },
        { 'ih',         buffer = bufnr, desc = 'Git hunk (text object)', mode = { 'o', 'x' } },
      })
    end

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal {
          ']c',
          bang = true
        }
      else
        gitsigns.nav_hunk 'next'
      end
    end, {
      desc = 'Jump to next git [c]hange'
    })

    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal {
          '[c',
          bang = true
        }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, {
      desc = 'Jump to previous git [c]hange'
    })

    -- Actions
    -- visual mode
    map('v', '<leader>hs', function()
      gitsigns.stage_hunk {vim.fn.line '.', vim.fn.line 'v'}
    end, {
      desc = 'git [s]tage hunk'
    })
    map('v', '<leader>hr', function()
      gitsigns.reset_hunk {vim.fn.line '.', vim.fn.line 'v'}
    end, {
      desc = 'git [r]eset hunk'
    })
    -- normal mode
    map('n', '<leader>hs', gitsigns.stage_hunk, {
      desc = 'git [s]tage hunk'
    })
    map('n', '<leader>hr', gitsigns.reset_hunk, {
      desc = 'git [r]eset hunk'
    })
    map('n', '<leader>hS', gitsigns.stage_buffer, {
      desc = 'git [S]tage buffer'
    })
    map('n', '<leader>hR', gitsigns.reset_buffer, {
      desc = 'git [R]eset buffer'
    })
    map('n', '<leader>hp', gitsigns.preview_hunk, {
      desc = 'git [p]review hunk'
    })
    map('n', '<leader>hi', gitsigns.preview_hunk_inline, {
      desc = 'git preview hunk [i]nline'
    })
    map('n', '<leader>hb', function()
      gitsigns.blame_line {
        full = true
      }
    end, {
      desc = 'git [b]lame line'
    })
    map('n', '<leader>hd', gitsigns.diffthis, {
      desc = 'git [d]iff against index'
    })
    map('n', '<leader>hD', function()
      gitsigns.diffthis '@'
    end, {
      desc = 'git [D]iff against last commit'
    })
    map('n', '<leader>hQ', function()
      gitsigns.setqflist 'all'
    end, {
      desc = 'git hunk [Q]uickfix list (all files in repo)'
    })
    map('n', '<leader>hq', gitsigns.setqflist, {
      desc = 'git hunk [q]uickfix list (all changes in this file)'
    })
    -- Toggles
    map('n', '<leader>tb', gitsigns.toggle_current_line_blame, {
      desc = '[T]oggle git show [b]lame line'
    })
    map('n', '<leader>tw', gitsigns.toggle_word_diff, {
      desc = '[T]oggle git intra-line [w]ord diff'
    })

    -- Text object
    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
  end
}

-- ### GIT COMMANDS (terminal)
local function git_run(args, label)
  local result = vim.fn.system(args)
  local ok = vim.v.shell_error == 0
  vim.notify(
    ok and (label .. ' OK') or result:gsub('\n$', ''),
    ok and vim.log.levels.INFO or vim.log.levels.ERROR
  )
end

vim.keymap.set('n', '<leader>ga', function()
  git_run({ 'git', 'add', '-A' }, 'git add -A')
end, { desc = '[G]it [A]dd all' })

vim.keymap.set('n', '<leader>gc', function()
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if msg and msg ~= '' then
      git_run({ 'git', 'commit', '-m', msg }, 'git commit')
    end
  end)
end, { desc = '[G]it [C]ommit' })

vim.keymap.set('n', '<leader>gps', function()
  git_run({ 'git', 'push' }, 'git push')
end, { desc = '[G]it [P]u[s]h' })

vim.keymap.set('n', '<leader>gpl', function()
  git_run({ 'git', 'pull' }, 'git pull')
end, { desc = '[G]it [P]u[l]l' })

local ok, wk = pcall(require, 'which-key')
if ok then
  wk.add({ { '<leader>g', group = '[G]it' } })
end
