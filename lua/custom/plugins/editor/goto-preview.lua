-- goto-preview.nvim: peek definition trong floating window — giống VSCode Peek Definition (terminal only)
-- Floating window mở buffer thật của file đích nên edit được luôn, không phải bản preview read-only
-- https://github.com/rmagatti/goto-preview
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'rmagatti/goto-preview' }

require('goto-preview').setup {
  default_mappings = false,
  -- Esc chỉ đóng preview window khi cursor đang ở trong chính preview đó (buffer-local),
  -- không đụng đến keymap Esc global (nohlsearch, xem init.lua)
  post_open_hook = function(_, preview_buf)
    vim.keymap.set('n', '<Esc>', require('goto-preview').close_all_win, {
      buffer = preview_buf,
      desc = 'Đóng preview window',
    })
  end,
}

-- ### GOTO PREVIEW KEYMAPS
-- gp  → peek definition (giống hệt 'gp' bên VSCode, xem vscode.lua)
-- gpt → peek type definition
-- gpi → peek implementation
-- gpD → peek declaration
-- gpr → peek references
-- gP  → đóng tất cả preview window đang mở (từ bất kỳ đâu)
-- Esc → đóng preview (chỉ khi đang ở trong preview window)
-- LƯU Ý: vì có gpt/gpi/gpD/gpr (3 ký tự, cùng bắt đầu 'gp'), Neovim sẽ đợi timeoutlen
-- (300ms, xem init.lua) sau khi gõ 'gp' trước khi chạy definition, để chờ ký tự thứ 3.
vim.keymap.set('n', 'gp', require('goto-preview').goto_preview_definition, { desc = 'Peek definition' })
vim.keymap.set('n', 'gpt', require('goto-preview').goto_preview_type_definition, { desc = 'Peek type definition' })
vim.keymap.set('n', 'gpi', require('goto-preview').goto_preview_implementation, { desc = 'Peek implementation' })
vim.keymap.set('n', 'gpD', require('goto-preview').goto_preview_declaration, { desc = 'Peek declaration' })
vim.keymap.set('n', 'gpr', require('goto-preview').goto_preview_references, { desc = 'Peek references' })
vim.keymap.set('n', 'gP', require('goto-preview').close_all_win, { desc = 'Đóng preview window' })
