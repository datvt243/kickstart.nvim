-- nvim-colorizer.lua (fork catgoose, đang maintain): tô màu ngay trong buffer
-- cho hex/rgb/hsl/tên màu CSS/Tailwind... Cần Neovim 0.10+. (terminal only)
-- https://github.com/catgoose/nvim-colorizer.lua
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'catgoose/nvim-colorizer.lua' }

-- ### COLORIZER — tô màu theo giá trị màu tìm thấy trong code.
-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  -- Bật cho mọi filetype; có thể đổi thành { 'css', 'html', 'javascript', ... }
  filetypes = { '*' },

  user_default_options = {
    -- Tô tên màu CSS (Blue, red, ...)
    names = true,

    -- Hex: #RGB / #RGBA
    RGB = true,
    -- Hex: #RRGGBB
    RRGGBB = true,
    -- Hex có alpha: #RRGGBBAA (tắt vì dễ nhầm với hex thường)
    RRGGBBAA = false,

    -- Hàm rgb()/rgba()
    rgb_fn = true,
    -- Hàm hsl()/hsla()
    hsl_fn = true,

    -- Cú pháp màu CSS nói chung (bật cả rgb_fn + hsl_fn + names)
    css = true,
    -- Chỉ các hàm màu CSS
    css_fn = true,

    -- Nhận diện class màu Tailwind (bg-red-500, text-blue-300, ...)
    tailwind = true,

    -- Kiểu hiển thị: 'background' tô nền, 'foreground' tô chữ,
    -- 'virtualtext' hiện ô màu bằng virtual text bên cạnh
    mode = 'background',

    -- Tự chọn màu chữ tương phản khi mode = 'background'
    virtualtext = '■',
  },
}

require('colorizer').setup(config)
