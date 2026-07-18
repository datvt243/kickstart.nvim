-- render-markdown.nvim: render markdown ngay trong buffer (heading, bullet, table, checkbox,
-- code block...) trong khi vẫn đang gõ/sửa raw text — không cần mở browser (terminal only)
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
require('render-markdown').setup {}
