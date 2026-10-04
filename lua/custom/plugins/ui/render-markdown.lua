-- render-markdown.nvim: render markdown ngay trong buffer (heading, bullet, table, checkbox,
-- code block...) trong khi vẫn đang gõ/sửa raw text — không cần mở browser (terminal only)
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
if vim.g.vscode ~= nil then return end

vim.pack.add { gh 'MeanderingProgrammer/render-markdown.nvim' }
-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  -- Tắt render công thức LaTeX: cần parser `latex` + utftex/latex2text, không dùng tới
  latex = { enabled = false },
}

require('render-markdown').setup(config)
