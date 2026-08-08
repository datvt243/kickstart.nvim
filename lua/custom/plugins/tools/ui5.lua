-- ui5-language-assistant: LSP cho SAPUI5/OpenUI5 XML views (completion class/aggregation/property
-- theo UI5 metadata, hover, quick-fix) — SAP chính chủ, 58 sao, đang bảo trì (terminal only)
-- KHÔNG có Mason package, KHÔNG có CLI/bin riêng — chỉ export module để VSCode nhúng qua Node IPC,
-- nên phải cài thủ công + bridge sang stdio bằng ui5-lsp-wrapper.js (cùng thư mục).
-- Cài thủ công (Mason không quản được): npm install -g @ui5-language-assistant/language-server
-- (yêu cầu Node.js >= 22). Chỉ attach trong project có ui5.yaml hoặc manifest.json (root_markers) —
-- không tự nhận diện *.view.xml/*.fragment.xml riêng vì Neovim LSP client chỉ lọc theo filetype.
-- https://github.com/SAP/ui5-language-assistant
if vim.g.vscode ~= nil then return end
if vim.fn.executable 'node' ~= 1 then return end

local wrapper = vim.fn.stdpath 'config' .. '/lua/custom/plugins/tools/ui5-lsp-wrapper.js'

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup bên dưới dùng lại ═══
local config = {
  cmd = { 'node', wrapper, '--stdio' },
  filetypes = { 'xml' },
  root_markers = { 'ui5.yaml', 'manifest.json' },
}

vim.lsp.config('ui5_language_assistant', config)
vim.lsp.enable 'ui5_language_assistant'
