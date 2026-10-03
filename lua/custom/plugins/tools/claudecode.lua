-- claudecode.nvim: tích hợp Claude Code CLI vào Neovim — toggle terminal, gửi selection,
-- accept/deny diff (terminal only)
-- https://github.com/coder/claudecode.nvim
if vim.g.vscode ~= nil then return end

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
  -- terminal.split_width_percentage: độ rộng split Claude Code (mặc định plugin là 0.30
  -- = 30% chiều rộng màn hình); tăng lên 0.4 cho split rộng hơn.
  -- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
  local config = {
    focus_after_send = true,
    terminal = { auto_insert = true, split_width_percentage = 0.4 },
  }
  require('claudecode').setup(config)
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

-- claudecode.nvim cache terminal buffer/job: toggle lại chỉ focus buffer cũ, KHÔNG spawn
-- job mới theo cwd hiện tại (xem native.lua open_terminal() -> is_valid()) — nên đổi project
-- (project.nvim <leader>sp hoặc tự detect root) vẫn giữ session CLI cũ, process cũ đứng yên ở
-- cwd cũ. Kill terminal cũ ngay khi DirChanged để lần mở tiếp theo (<leader>cc) spawn job mới
-- đúng cwd project hiện tại, tránh lẫn ngữ cảnh giữa 2 project (issue #3).
vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('claudecode-close-on-project-switch', { clear = true }),
  callback = function(event)
    if event.match ~= 'global' then return end
    if not (package.loaded.claudecode and package.loaded.claudecode.state and package.loaded.claudecode.state.initialized) then return end
    local bufnr = require('claudecode.terminal').get_active_terminal_bufnr()
    if bufnr then vim.api.nvim_buf_delete(bufnr, { force = true }) end
  end,
})
