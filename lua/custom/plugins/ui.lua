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
local function gh(repo)
  return 'https://github.com/' .. repo
end

-- guess-indent: chạy ở cả 2 môi trường
vim.pack.add {gh 'NMAC427/guess-indent.nvim'}
require('guess-indent').setup {}

-- mini.nvim: text objects và surround — hoạt động ở cả terminal lẫn VSCode
vim.pack.add {gh 'nvim-mini/mini.nvim'}

-- ### MINI.AI — TEXT OBJECTS MỞ RỘNG
-- va)   → chọn xung quanh )
-- yiiq  → yank trong quote
-- ci'   → thay đổi trong '
-- aa/ii → around/inside next object
require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii'
  },
  n_lines = 500
}

-- ### MINI.SURROUND
-- saiw) → thêm () quanh word
-- sd'   → xóa ''
-- sr)'  → thay ) bằng '
require('mini.surround').setup()

if not is_vscode then
  if vim.g.have_nerd_font then
    vim.pack.add {gh 'nvim-tree/nvim-web-devicons'}
  end

  -- Ký hiệu git ở gutter (thêm/xóa/sửa dòng)
  vim.pack.add {gh 'lewis6991/gitsigns.nvim'}
  require('gitsigns').setup {
    signs = {
      add = {
        text = '+'
      }, ---@diagnostic disable-line: missing-fields
      change = {
        text = '~'
      }, ---@diagnostic disable-line: missing-fields
      delete = {
        text = '_'
      }, ---@diagnostic disable-line: missing-fields
      topdelete = {
        text = '‾'
      }, ---@diagnostic disable-line: missing-fields
      changedelete = {
        text = '~'
      } ---@diagnostic disable-line: missing-fields
    }
  }

  -- Hiển thị gợi ý phím khi bấm leader
  vim.pack.add {gh 'folke/which-key.nvim'}
  require('which-key').setup {
    delay = 0,
    plugins = {
      spelling = true,
      presets = {}
    },
    show_help = false,
    icons = {
      mappings = vim.g.have_nerd_font
    },
    spec = {{
      '<leader>s',
      group = '[S]earch',
      mode = {'n', 'v'}
    }, {
      '<leader>t',
      group = '[T]oggle'
    }, {
      '<leader>h',
      group = 'Git [H]unk',
      mode = {'n', 'v'}
    }, {
      'gr',
      group = 'LSP Actions',
      mode = {'n'}
    }, {
      '<leader>s',
      hidden = false,
      mode = {'n', 'v'}
    }}
  }

  -- Colorscheme: tokyonight-night
  -- Đổi theme: thay 'tokyonight-night' → storm / moon / day
  vim.pack.add {gh 'folke/tokyonight.nvim'}
  ---@diagnostic disable-next-line: missing-fields
  require('tokyonight').setup {
    styles = {
      comments = {
        italic = false
      }
    }
  }
  vim.cmd.colorscheme 'tokyonight-night'

  -- Highlight TODO, NOTE, FIXME, HACK, WARN trong comment
  vim.pack.add {gh 'folke/todo-comments.nvim'}
  require('todo-comments').setup {
    signs = false
  }

  -- ### FLASH.NVIM — NHẢY NHANH (thay thế vim-sneak + vim-easymotion)
  -- s{2 ký tự}   → nhảy đến vị trí khớp trong file (sneak)
  -- S            → chọn node treesitter xung quanh cursor
  -- r (operator) → remote flash, vd: yr{ab} để yank từ xa
  -- <leader>.    → fuzzy jump kiểu easymotion
  vim.pack.add {gh 'folke/flash.nvim'}
  require('flash').setup {
    modes = {
      search = {
        enabled = false
      }, -- không override / và ?
      char = {
        enabled = false
      } -- không override f/t/F/T
    }
  }
  vim.keymap.set({'n', 'x', 'o'}, 's', function()
    require('flash').jump()
  end, {
    desc = 'Flash jump'
  })
  vim.keymap.set({'n', 'x', 'o'}, 'S', function()
    require('flash').treesitter()
  end, {
    desc = 'Flash treesitter'
  })
  vim.keymap.set('o', 'r', function()
    require('flash').remote()
  end, {
    desc = 'Flash remote operator'
  })
  vim.keymap.set({'n', 'x'}, '<leader>.', function()
    require('flash').jump {
      search = {
        mode = 'fuzzy'
      }
    }
  end, {
    desc = 'Flash fuzzy jump'
  })

  -- Statusline tối giản
  local statusline = require 'mini.statusline'
  statusline.setup {
    use_icons = vim.g.have_nerd_font
  }
  ---@diagnostic disable-next-line: duplicate-set-field
  statusline.section_location = function()
    return '%2l:%-2v'
  end
end
