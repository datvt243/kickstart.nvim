-- mini.surround + mini.move: surround, di chuyển dòng/selection (cả terminal lẫn VSCode)
-- guess-indent: tự detect tabsize/expandtab khi mở file (cả 2 môi trường)
-- mini.ai → xem lua/custom/plugins/coding/mini-ai.lua
local function gh(repo) return 'https://github.com/' .. repo end

-- guess-indent: chạy ở cả 2 môi trường
vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {}

-- mini.nvim: surround và move — hoạt động ở cả terminal lẫn VSCode
vim.pack.add { gh 'nvim-mini/mini.nvim' }

-- ### MINI.SURROUND
-- saiw) → thêm () quanh word
-- sd'   → xóa ''
-- sr)'  → thay ) bằng '
require('mini.surround').setup()

-- ### MINI.MOVE — di chuyển line/selection
-- Normal : gh/gj/gk/gl
-- Visual : gh/gj/gk/gl
-- (Không alias <Up>/<Down> — mũi tên phải giữ nguyên chức năng di chuyển con trỏ)
-- ═══ CONFIG (mini.move) — chỉnh giá trị ở đây; setup(move_config) bên dưới dùng lại ═══
local move_config = {
  mappings = {
    left = 'gh',
    right = 'gl',
    down = 'gj',
    up = 'gk',
    line_left = 'gh',
    line_right = 'gl',
    line_down = 'gj',
    line_up = 'gk',
  },
}

require('mini.move').setup(move_config)
