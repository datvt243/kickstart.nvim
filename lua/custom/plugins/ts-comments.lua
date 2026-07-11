-- ts-comments.nvim: comment string chính xác theo Treesitter injection (JSX, Vue, Svelte, Astro...)
-- Bổ trợ cho gcc/gc built-in của Neovim (không thay thế), cần Neovim >= 0.10
-- https://github.com/folke/ts-comments.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'folke/ts-comments.nvim' }

require('ts-comments').setup {}
