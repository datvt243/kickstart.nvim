-- mini.ai: text objects mở rộng, thuộc mini.nvim (cả terminal lẫn VSCode)
-- https://github.com/nvim-mini/mini.nvim (module: mini.ai)
-- ### MINI.AI — TEXT OBJECTS MỞ RỘNG
-- va)/yiiq/ci' → around/inside quote/bracket built-in; aa/ii → around/inside next object
-- af/if → around/inside function definition (treesitter); ac/ic → around/inside class (treesitter)
-- Built-in: a)/i) a]/i] a}/i} a>/i> a'/i' a"/i" af(call)/if(call) aa/ia(argument)
local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'nvim-mini/mini.nvim' }

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
