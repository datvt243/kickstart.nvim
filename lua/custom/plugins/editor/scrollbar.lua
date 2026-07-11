-- nvim-scrollbar: hiển thị git change (add/change/delete) và diagnostics
-- trên thanh scrollbar bên phải, giống overview ruler của VSCode (terminal only)
-- https://github.com/petertriho/nvim-scrollbar
if vim.g.vscode ~= nil then
  return
end

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'petertriho/nvim-scrollbar' }

require('scrollbar').setup {
  handlers = {
    gitsigns = true, -- cần gitsigns.nvim (kickstart/plugins/gitsigns.lua) đã bật
  },
}

-- gitsigns.nvim được load ở Section 10 (sau custom.plugins), nên đợi VimEnter
-- để chắc chắn plugin đã có trên runtimepath trước khi gắn handler
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    require('scrollbar.handlers.gitsigns').setup()
  end,
})
