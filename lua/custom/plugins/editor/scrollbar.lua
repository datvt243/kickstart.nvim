-- nvim-scrollbar: hiển thị git change (add/change/delete) và diagnostics
-- trên thanh scrollbar bên phải, giống overview ruler của VSCode (terminal only)
-- https://github.com/petertriho/nvim-scrollbar
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'petertriho/nvim-scrollbar' }

-- KHÔNG bật handlers.gitsigns ở đây: scrollbar.setup() gọi handler.setup() của
-- gitsigns NGAY LẬP TỨC (đồng bộ) khi thấy handlers.gitsigns = true, nhưng
-- gitsigns.nvim chỉ được load ở Section 10 (sau custom.plugins) nên lúc này
-- chưa có -> luôn báo "gitsigns.nvim module not available". Gắn handler thủ công
-- bên dưới, sau khi gitsigns chắc chắn đã load.
require('scrollbar').setup {}

-- gitsigns.nvim được load ở Section 10 (sau custom.plugins), nên đợi tick tiếp theo
-- của event loop để chắc chắn plugin đã có trên runtimepath trước khi gắn handler.
-- Dùng vim.schedule thay vì autocmd VimEnter vì VimEnter chỉ fire 1 lần/session —
-- :ReloadConfig chạy lại file này sau khi VimEnter đã fire nên autocmd sẽ không bao giờ chạy.
vim.schedule(function() require('scrollbar.handlers.gitsigns').setup() end)
