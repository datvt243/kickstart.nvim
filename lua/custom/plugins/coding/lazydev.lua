-- lazydev.nvim: cấu hình lua_ls chuyên biệt cho code Neovim config/plugin (terminal only)
-- Cho lua_ls biết `vim` global, type API Neovim, và resolve require() tới đúng plugin đã cài
-- Chỉ kích hoạt cho file .lua, không ảnh hưởng project Lua thường
-- https://github.com/folke/lazydev.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'folke/lazydev.nvim' }
require('lazydev').setup {
  library = {
    -- Nạp type luv khi gặp vim.uv
    { path = '${3rd}/luv/library', words = { 'vim%.uv' } }
  }
}
