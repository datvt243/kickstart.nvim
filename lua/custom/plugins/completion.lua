-- Autocomplete: blink.cmp + LuaSnip
-- blink.cmp: engine autocomplete hiện đại, nhanh hơn nvim-cmp, dùng Rust
-- LuaSnip: snippet engine; blink.cmp dùng làm nguồn snippet
-- https://github.com/saghen/blink.cmp
-- https://github.com/L3MON4D3/LuaSnip

local function gh(repo)
  return 'https://github.com/' .. repo
end

if vim.g.vscode ~= nil then
  return
end

vim.pack.add {{
  src = gh 'L3MON4D3/LuaSnip',
  version = vim.version.range '2.*'
}}
require('luasnip').setup {}

-- Bỏ comment để dùng friendly-snippets (snippet có sẵn cho nhiều ngôn ngữ):
-- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
-- require('luasnip.loaders.from_vscode').lazy_load()

vim.pack.add {{
  src = gh 'saghen/blink.cmp',
  version = vim.version.range '1.*'
}}
require('blink.cmp').setup {
  keymap = {
    -- ### BLINK.CMP KEYMAPS (preset: 'default')
    -- <C-y>         → chấp nhận completion
    -- <C-space>     → mở menu / mở docs
    -- <C-n> / <C-p> → item tiếp / trước
    -- <C-e>         → đóng menu
    -- <C-k>         → toggle signature help
    -- <tab>/<S-tab> → di chuyển trong snippet
    preset = 'default'
  },
  appearance = {
    nerd_font_variant = 'mono'
  },
  completion = {
    documentation = {
      auto_show = false,
      auto_show_delay_ms = 500
    }
  },
  sources = {
    default = {'lsp', 'path', 'snippets'}
  },
  snippets = {
    preset = 'luasnip'
  },
  fuzzy = {
    implementation = 'lua'
  },
  signature = {
    enabled = true
  }
}
