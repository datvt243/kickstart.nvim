-- todo-comments.nvim: highlight TODO/FIXME/NOTE/HACK/WARN trong comment (terminal only)
-- https://github.com/folke/todo-comments.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/todo-comments.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  signs = false,
}

require('todo-comments').setup(config)
