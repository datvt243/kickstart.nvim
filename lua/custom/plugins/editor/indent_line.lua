-- indent-blankline.nvim (ibl): hiển thị indent guide, kể cả ở dòng trống (terminal only)
-- https://github.com/lukas-reineke/indent-blankline.nvim
if vim.g.vscode ~= nil then return end

vim.pack.add {
  'https://github.com/lukas-reineke/indent-blankline.nvim',
}

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
-- exclude.filetypes ghi đè (không merge cộng dồn) danh sách mặc định của ibl
-- khi key trùng theo thứ tự index (vim.tbl_deep_extend 'keep'), nên liệt kê
-- đủ default gốc + 'dashboard' tránh mất exclude của mấy filetype khác
local config = {
  exclude = {
    filetypes = {
      'lspinfo',
      'packer',
      'checkhealth',
      'help',
      'man',
      'gitcommit',
      'TelescopePrompt',
      'TelescopeResults',
      'dashboard',
      '',
    },
  },
}

require('ibl').setup(config)
