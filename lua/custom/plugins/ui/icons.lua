-- mini.icons: cấp icon theo filetype (thuộc mini.nvim, terminal only) — thay nvim-web-devicons
-- mock_nvim_web_devicons() giả lập API của nvim-web-devicons, để các plugin gọi thẳng
-- require('nvim-web-devicons') (Telescope, Neo-tree, lualine, bufferline...) vẫn nhận icon
-- bình thường mà không cần sửa gì ở các plugin đó, và không cần cài nvim-web-devicons thật.
--
-- LƯU Ý: file này được require TRƯỚC (xem lua/custom/plugins/init.lua) để đảm bảo mock
-- đã sẵn sàng trước khi các plugin khác gọi require('nvim-web-devicons') lúc setup().
-- https://github.com/nvim-mini/mini.icons
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'nvim-mini/mini.nvim' }

require('mini.icons').setup {}
require('mini.icons').mock_nvim_web_devicons()
