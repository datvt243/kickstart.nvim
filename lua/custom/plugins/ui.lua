-- UI plugins (chạy ở cả terminal lẫn VSCode trừ khi ghi chú khác)
-- mini.nvim: bộ plugin nhỏ gọn — mini.ai (text objects), mini.surround, mini.statusline
-- guess-indent: tự detect tabsize/expandtab khi mở file
-- tokyonight: colorscheme (terminal only)
-- which-key: hiển thị gợi ý keymap khi gõ leader (terminal only)
-- gitsigns: ký hiệu git diff trong gutter + blame inline (terminal only)
-- todo-comments: highlight TODO/FIXME/NOTE trong code (terminal only)
-- flash.nvim: nhảy nhanh đến bất kỳ vị trí nào bằng s/S (terminal only)
--
local is_vscode = vim.g.vscode ~= nil
local function gh(repo) return 'https://github.com/' .. repo end

-- guess-indent: chạy ở cả 2 môi trường
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

-- mini.nvim: text objects và surround — hoạt động ở cả terminal lẫn VSCode
vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- ### MINI.AI — TEXT OBJECTS MỞ RỘNG
-- va)   → chọn xung quanh )
-- yiiq  → yank trong quote
-- ci'   → thay đổi trong '
-- aa/ii → around/inside next object
-- ### MINI.AI
-- af/if → around/inside function definition (treesitter)
-- ac/ic → around/inside class (treesitter)
-- Built-in: a)/i) a]/i] a}/i} a>/i> a'/i' a"/i" af(call)/if(call) aa/ia(argument)
require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
  custom_textobjects = {
    f = require('mini.ai').gen_spec.treesitter {
      a = '@function.outer',
      i = '@function.inner',
    },
    c = require('mini.ai').gen_spec.treesitter {
      a = '@class.outer',
      i = '@class.inner',
    },
  },
}

-- ### MINI.SURROUND
-- saiw) → thêm () quanh word
-- sd'   → xóa ''
-- sr)'  → thay ) bằng '
require('mini.surround').setup()

-- ### MINI.MOVE — di chuyển line/selection
-- Normal : gh/gj/gk/gl  hoặc  <Up>/<Down>
-- Visual : gh/gj/gk/gl  hoặc  <Up>/<Down>
require('mini.move').setup {
  mappings = {
    left = 'gh',
    right = 'gl',
    down = 'gj',
    up = 'gk',
    line_left = 'gh',
    line_right = 'gl',
    line_down = 'gj',
    line_up = 'gk',
  },
}
-- Arrow key aliases (VSCode only — terminal dùng arrow keys để navigate cursor)
if is_vscode then
  local _move = require 'mini.move'
  vim.keymap.set('n', '<Up>', function() _move.move_line 'up' end, { desc = 'Move line up' })
  vim.keymap.set('n', '<Down>', function() _move.move_line 'down' end, { desc = 'Move line down' })
  vim.keymap.set('x', '<Up>', function() _move.move_selection 'up' end, { desc = 'Move selection up' })
  vim.keymap.set('x', '<Down>', function() _move.move_selection 'down' end, { desc = 'Move selection down' })
end

-- ### FLASH.NVIM — hoạt động ở cả terminal lẫn VSCode
-- Flash là Neovim plugin thuần: labels render qua extmarks, input qua Neovim channel
-- → không conflict với vscode-neovim (khác Jumpy vốn hook 'type' command của VSCode)
-- <leader>j → jump word (thay Jumpy trong VSCode)
-- s / S     → jump / treesitter (terminal, xem thêm trong block if not is_vscode)
vim.pack.add { gh 'folke/flash.nvim' }
require('flash').setup {
  modes = {
    search = { enabled = false }, -- không override / và ?
    char = { enabled = false }, -- không override f/t/F/T
  },
}
vim.keymap.set({ 'n', 'x', 'o' }, '<leader>j', function() require('flash').jump() end, { desc = 'Flash jump' })

if not is_vscode then
  if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end

  -- Hiển thị gợi ý phím khi bấm leader
  vim.pack.add { gh 'folke/which-key.nvim' }
  require('which-key').setup {
    delay = 0,
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
      {
        '<leader>h',
        group = 'Git [H]unk',
        mode = { 'n', 'v' },
      },
      {
        'gr',
        group = 'LSP Actions',
        mode = { 'n' },
      },
      {
        '<leader>s',
        hidden = false,
        mode = { 'n', 'v' },
      },
    },
  }

  -- Colorscheme: tokyonight-night
  -- Đổi theme: thay 'tokyonight-night' → storm / moon / day
  vim.pack.add { gh 'folke/tokyonight.nvim' }
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup {
    styles = {
      comments = {
        italic = false,
      },
    },
  }
  vim.cmd.colorscheme 'tokyonight-night'

  -- Highlight TODO, NOTE, FIXME, HACK, WARN trong comment
  vim.pack.add { gh 'folke/todo-comments.nvim' }
  require('todo-comments').setup {
    signs = false,
  }

  -- ### FLASH.NVIM — terminal-only keymaps (plugin đã load ở trên)
  -- s{2 ký tự}   → nhảy đến vị trí khớp trong file (sneak)
  -- S            → chọn node treesitter xung quanh cursor
  -- r (operator) → remote flash, vd: yr{ab} để yank từ xa
  -- <leader>.    → fuzzy jump kiểu easymotion
  vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, {
    desc = 'Flash jump',
  })
  vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, {
    desc = 'Flash treesitter',
  })
  vim.keymap.set('o', 'r', function() require('flash').remote() end, {
    desc = 'Flash remote operator',
  })
  vim.keymap.set({ 'n', 'x' }, '<leader>.', function()
    require('flash').jump {
      search = {
        mode = 'fuzzy',
      },
    }
  end, {
    desc = 'Flash fuzzy jump',
  })

  -- Statusline tối giản
  local statusline = require 'mini.statusline'
  statusline.setup {
    use_icons = vim.g.have_nerd_font,
  }
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function() return '%2l:%-2v' end
end
