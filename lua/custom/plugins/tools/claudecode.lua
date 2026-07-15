-- claudecode.nvim: tích hợp Claude Code CLI vào Neovim — toggle terminal, gửi selection,
-- accept/deny diff (terminal only)
-- https://github.com/coder/claudecode.nvim
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'coder/claudecode.nvim' }

-- Guard setup{}: :ReloadConfig require lại file này (namespace custom.*) nhưng module
-- 'claudecode' không bị clear cache nên server cũ vẫn còn sống — gọi setup{} lần nữa
-- (auto_start mặc định true) sẽ tự start lại và bị chính plugin warn "already running".
-- Bỏ qua nếu đã init để tránh warning vô hại đó.
if not (package.loaded.claudecode and package.loaded.claudecode.state and package.loaded.claudecode.state.initialized) then
  -- focus_after_send: sau khi gửi selection thì tự nhảy vào terminal Claude luôn.
  -- Provider mặc định là native (terminal trong Neovim, focus được) nên option này
  -- có tác dụng và KHÔNG bị plugin cảnh báo (warning provider chỉ xảy ra với
  -- provider "none"/"external" chạy Claude ngoài Neovim).
  -- terminal.auto_insert = true: khi focus vào terminal thì vào luôn insert mode
  -- (plugin gọi `startinsert`) để gõ tiếp yêu cầu ngay, không phải bấm `i`.
  require('claudecode').setup {
    focus_after_send = true,
    terminal = { auto_insert = true },
  }
end

-- ### CLAUDE CODE
-- Bật/tắt terminal Claude Code
vim.keymap.set('n', '<leader>cc', '<cmd>ClaudeCode<cr>', { desc = '[C]laude [C]ode toggle' })

-- Focus vào terminal Claude Code (không toggle, chỉ nhảy vào)
vim.keymap.set('n', '<leader>cf', '<cmd>ClaudeCodeFocus<cr>', { desc = '[C]laude [F]ocus' })

-- Gửi vùng text đang chọn đến Claude; việc focus vào terminal do focus_after_send lo.
-- Dùng <cmd> để giữ nguyên visual range ('<,'>) và tránh race giữa Send (async) + Focus.
vim.keymap.set('v', '<leader>cs', '<cmd>ClaudeCodeSend<cr>', { desc = '[C]laude [S]end selection + focus' })

-- Thêm file đang chọn trong file explorer (Neo-tree...) vào context của Claude
-- Chỉ bind trong buffer của các filetype file-explorer/picker, không phải global
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('claudecode-tree-add', {
    clear = true,
  }),
  pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw', 'snacks_picker_list' },
  callback = function(event) vim.keymap.set('n', '<leader>cs', '<cmd>ClaudeCodeTreeAdd<cr>', { buffer = event.buf, desc = 'Add file' }) end,
})

-- Chọn model Claude
vim.keymap.set('n', '<leader>cm', '<cmd>ClaudeCodeSelectModel<cr>', { desc = '[C]laude [M]odel' })

-- Chấp nhận / từ chối diff Claude đề xuất
vim.keymap.set('n', '<leader>ca', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = '[C]laude [A]ccept diff' })
vim.keymap.set('n', '<leader>cd', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = '[C]laude [D]eny diff' })
