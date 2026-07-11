-- Auto-loader: require đệ quy mọi file .lua trong custom/plugins/ (kể cả subfolder editor/,
-- coding/, colorscheme/, formatting/, ui/, treesitter/, tools/) — thêm file mới vào đây là
-- tự động được load, không cần sửa file này hay init.lua.

local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')

-- ui/icons.lua phải load TRƯỚC toàn bộ các file khác: nó gọi mini.icons.mock_nvim_web_devicons(),
-- các plugin khác (Telescope, Neo-tree, lualine, bufferline...) cần thấy mock này đã sẵn sàng
-- trước khi chính chúng gọi require('nvim-web-devicons') lúc setup(). Thứ tự duyệt thư mục
-- (vim.fs.dir) không đảm bảo, nên phải require thủ công ở đây trước vòng lặp load_dir.
require 'custom.plugins.ui.icons'

-- Duyệt đệ quy để load cả các file .lua trong subfolder (vd: custom/plugins/editor/)
local function load_dir(dir, module_prefix)
  for file_name, type in vim.fs.dir(dir) do
    if type == 'file' and file_name:match '%.lua$' and not (module_prefix == 'custom.plugins' and file_name == 'init.lua') then
      local module = file_name:gsub('%.lua$', '')
      require(module_prefix .. '.' .. module)
    elseif type == 'directory' then
      load_dir(vim.fs.joinpath(dir, file_name), module_prefix .. '.' .. file_name)
    end
  end
end

load_dir(plugins_dir, 'custom.plugins')
