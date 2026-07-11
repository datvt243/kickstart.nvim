-- codesnap.nvim: chụp đoạn code đang chọn thành ảnh đẹp (giống CodeSnap)
-- https://github.com/mistricky/codesnap.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo)
  return 'https://github.com/' .. repo
end

vim.pack.add { gh 'mistricky/codesnap.nvim' }

require('codesnap').setup {}

-- ### CODESNAP KEYMAPS (visual mode)
-- Copy snapshot của selection vào clipboard
vim.keymap.set('x', '<leader>cp', '<cmd>CodeSnap<CR>', { desc = 'CodeSnap: copy ảnh vào clipboard' })
-- Lưu snapshot ra file (nhập đường dẫn)
local default_snapshot_path = vim.fn.has 'win32' == 1 and '~/Desktop/codesnap/snapshot.png' or '~/Desktop/codesnap/snapshot.png'

vim.keymap.set('x', '<leader>cP', function()
  vim.ui.input({
    prompt = 'Lưu snapshot vào: ',
    default = vim.fn.expand(default_snapshot_path)
  }, function(path)
    if path and path ~= '' then
      vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
      vim.cmd('CodeSnapSave ' .. path)
    end
  end)
end, { desc = 'CodeSnap: lưu ảnh ra file' })
