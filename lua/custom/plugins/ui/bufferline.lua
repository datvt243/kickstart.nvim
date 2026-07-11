-- bufferline.nvim: thanh tab hiển thị buffer đang mở ở trên cùng (giống tab bar VSCode)
-- Terminal only — VSCode đã có tab bar native
-- Dùng chung keymap buffer có sẵn: <S-h>/<S-l> chuyển buffer, <leader>bq đóng buffer (xem init.lua)
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

require('bufferline').setup {
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
