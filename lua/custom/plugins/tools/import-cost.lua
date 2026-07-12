-- vim-import-cost: hiển thị kích thước (KB) của mỗi import JS/TS, giống Import Cost (VSCode) (terminal only)
-- https://github.com/yardnsm/vim-import-cost
-- Keymap nổi bật: <leader>ic hiển thị KB, <leader>iC xóa hiển thị (chỉ buffer JS/TS)
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'yardnsm/vim-import-cost' }

-- ### IMPORT COST KEYMAPS (chỉ file JS/TS)
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('import-cost-keymaps', {
    clear = true,
  }),
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function(event)
    local map = function(keys, cmd, desc) vim.keymap.set('n', keys, cmd, { buffer = event.buf, desc = desc }) end
    -- Tính và hiển thị kích thước import trong buffer hiện tại
    map('<leader>ic', '<cmd>ImportCost<CR>', 'Import Cost: hiển thị KB')
    -- Xóa kích thước đang hiển thị
    map('<leader>iC', '<cmd>ImportCostClear<CR>', 'Import Cost: xóa hiển thị')
  end,
})
