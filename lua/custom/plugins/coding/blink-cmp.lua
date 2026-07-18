-- blink.cmp: engine autocomplete hiện đại, nhanh hơn nvim-cmp, dùng Rust (terminal only)
-- Dùng LuaSnip (coding/luasnip.lua) làm nguồn snippet
-- https://github.com/saghen/blink.cmp
if vim.g.vscode ~= nil then return end

vim.pack.add { {
  src = gh 'saghen/blink.cmp',
  version = vim.version.range '1.*',
} }
-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  keymap = {
    -- ### BLINK.CMP KEYMAPS (preset: 'default')
    -- <C-y>         → chấp nhận completion
    -- <C-space>     → mở menu / mở docs
    -- <C-n> / <C-p> → item tiếp / trước
    -- <C-e>         → đóng menu
    -- <C-k>         → toggle signature help
    -- <tab>/<S-tab> → di chuyển trong snippet
    preset = 'default',
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = {
      auto_show = false,
      auto_show_delay_ms = 500,
    },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },
  snippets = {
    preset = 'luasnip',
  },
  fuzzy = {
    implementation = 'lua',
  },
  signature = {
    enabled = true,
  },
}

require('blink.cmp').setup(config)
