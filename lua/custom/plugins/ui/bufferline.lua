-- bufferline.nvim: thanh tab hiển thị buffer đang mở ở trên cùng (giống tab bar VSCode)
-- LƯU Ý: tabline của bufferline là GLOBAL cho toàn bộ Neovim, không tách theo từng split
-- — nếu mở 2 split thì cũng chỉ có 1 dòng tab, không thể "mỗi split 1 tab riêng".
-- Nhu cầu "luôn thấy tên file dù focus sang cửa sổ khác/nhiều split" đã chuyển sang
-- winbar.lua (built-in Neovim, window-local) — xem file đó.
-- Terminal only — VSCode đã có tab bar native
-- https://github.com/akinsho/bufferline.nvim
if vim.g.vscode ~= nil then return end

-- Tắt mặc định (trước đây là optional plugin, opt-in qua init.lua Section 10)
-- Đổi thành true để bật
local enabled = false
if not enabled then return end

local function gh(repo) return 'https://github.com/' .. repo end

-- Icon: dùng mini.icons qua mock_nvim_web_devicons() (xem lua/custom/plugins/ui/icons.lua),
-- không cần cài nvim-web-devicons thật
vim.pack.add { gh 'akinsho/bufferline.nvim' }

-- Theo dõi buffer file "thật" gần nhất (bỏ qua Neo-tree, terminal, quickfix...) để
-- custom_filter bên dưới luôn lọc đúng file đang làm việc, kể cả khi buffer hiện tại
-- (nvim_get_current_buf) đang là Neo-tree/terminal do focus vừa chuyển sang đó.
-- Đăng ký autocmd này TRƯỚC khi gọi setup() để nó chạy trước autocmd redraw nội bộ
-- của bufferline trên cùng sự kiện BufEnter.
local last_file_buf = vim.api.nvim_get_current_buf()
vim.api.nvim_create_autocmd('BufEnter', {
  group = vim.api.nvim_create_augroup('bufferline-track-file', { clear = true }),
  callback = function(event)
    if vim.bo[event.buf].buftype == '' and vim.bo[event.buf].buflisted then last_file_buf = event.buf end
  end,
})

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  options = {
    mode = 'buffers',
    themable = true,
    numbers = 'none',
    indicator = { style = 'icon', icon = '▎' },
    buffer_close_icon = '󰅖',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    max_name_length = 18,
    max_prefix_length = 15,
    truncate_names = true,
    tab_size = 18,
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = function(count, level)
      local icon = level:match 'error' and ' ' or ' '
      return icon .. count
    end,
    color_icons = true,
    show_buffer_icons = true,
    show_buffer_close_icons = true,
    show_close_icon = false,
    show_tab_indicators = true,
    show_duplicate_prefix = true,
    persist_buffer_sort = true,
    move_wraps_at_ends = false,
    separator_style = 'thin',
    enforce_regular_tabs = false,
    always_show_bufferline = true,
    hover = { enabled = true, delay = 200, reveal = { 'close' } },
    -- Chỉ hiện 1 tab duy nhất: buffer file đang/vừa edit gần nhất (xem last_file_buf ở trên)
    custom_filter = function(buf) return buf == last_file_buf end,
    -- Đẩy tab bar sang phải khi Neo-tree đang mở, tránh đè lên sidebar
    offsets = {
      {
        filetype = 'neo-tree',
        text = 'File Explorer',
        highlight = 'Directory',
        separator = true,
      },
    },
  },
}

require('bufferline').setup(config)
