-- dashboard-nvim: màn hình chào khi mở Neovim không kèm file (terminal only)
-- Theme "hyper": header ASCII art + shortcuts + recent projects + MRU files
-- https://github.com/nvimdev/dashboard-nvim
-- Phím tắt trong dashboard: f find files, r recent files, g grep, c mở config, q quit
if vim.g.vscode ~= nil then return end

vim.pack.add { 'https://github.com/nvimdev/dashboard-nvim' }

require('dashboard').setup {
  theme = 'hyper',
  config = {
    header = {
      '',
      '███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗',
      '████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║',
      '██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║',
      '██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║',
      '██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║',
      '╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝',
      '',
    },
    shortcut = {
      {
        icon = ' ',
        desc = 'Find File',
        key = 'f',
        action = 'Telescope find_files',
      },
      {
        icon = ' ',
        desc = 'Recent Files',
        key = 'r',
        action = 'Telescope oldfiles',
      },
      {
        icon = ' ',
        desc = 'Grep',
        key = 'g',
        action = 'Telescope live_grep',
      },
      {
        icon = ' ',
        desc = 'Config',
        key = 'c',
        action = function() require('telescope.builtin').find_files { cwd = vim.fn.stdpath 'config' } end,
      },
      {
        icon = '󰩈 ',
        desc = 'Quit',
        key = 'q',
        action = 'qa',
      },
    },
    project = { enable = true, limit = 5 },
    mru = { limit = 8 },
    footer = {},
  },
}
