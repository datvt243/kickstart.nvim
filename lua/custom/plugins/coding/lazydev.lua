-- lazydev.nvim: cấu hình lua_ls chuyên biệt cho code Neovim config/plugin (terminal only)
-- Cho lua_ls biết `vim` global, type API Neovim, và resolve require() tới đúng plugin đã cài
-- Chỉ kích hoạt cho file .lua, không ảnh hưởng project Lua thường
-- https://github.com/folke/lazydev.nvim
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'folke/lazydev.nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  library = {
    -- Nạp type luv khi gặp vim.uv
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
  },
}

require('lazydev').setup(config)
