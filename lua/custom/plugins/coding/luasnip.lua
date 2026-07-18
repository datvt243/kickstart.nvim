-- LuaSnip: snippet engine, dùng làm nguồn snippet cho blink.cmp (terminal only)
-- https://github.com/L3MON4D3/LuaSnip
if vim.g.vscode ~= nil then return end

vim.pack.add { {
  src = gh 'L3MON4D3/LuaSnip',
  version = vim.version.range '2.*',
} }
require('luasnip').setup {}

-- Bỏ comment để dùng friendly-snippets (snippet có sẵn cho nhiều ngôn ngữ):
-- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
-- require('luasnip.loaders.from_vscode').lazy_load()
