-- nvim-ts-autotag: tự động đóng/đổi tên cặp thẻ HTML/JSX/TSX/Vue/Svelte... dựa trên treesitter (terminal only)
-- https://github.com/windwp/nvim-ts-autotag
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'windwp/nvim-ts-autotag' }

require('nvim-ts-autotag').setup {}
