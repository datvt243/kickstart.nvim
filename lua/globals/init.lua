-- Global helper methods dùng chung cho toàn config.
-- Được `require 'globals'` trong init.lua (Section 1) TRƯỚC khi load plugin, nên mọi
-- file plugin gọi thẳng các hàm ở đây mà không cần khai báo lại từng file.
--
-- THÊM GLOBAL MỚI:
--   1. Định nghĩa vào `_G` bên dưới (kèm comment mô tả).
--   2. Thêm tên hàm vào `Lua.diagnostics.globals` trong lua/custom/plugins/lsp.lua
--      để lua_ls không báo "undefined global".

-- gh 'user/repo' → 'https://github.com/user/repo' (rút gọn URL cho vim.pack.add)
function _G.gh(repo) return 'https://github.com/' .. repo end
