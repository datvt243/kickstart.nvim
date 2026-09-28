-- dashboard-nvim: màn hình chào khi mở Neovim không kèm file (terminal only)
-- Theme "hyper": header ASCII art + shortcuts + recent projects + MRU files
-- https://github.com/nvimdev/dashboard-nvim
-- Phím tắt trong dashboard: f find files, r recent files, g grep, c mở config, q quit
if vim.g.vscode ~= nil then return end

vim.pack.add { 'https://github.com/nvimdev/dashboard-nvim' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
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

require('dashboard').setup(config)

-- Ẩn số dòng (number/relativenumber), cursorline và diagnostics/lint (LSP,
-- linter...) riêng trên buffer dashboard, không đụng tới option toàn cục
-- ở lua/options.lua
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('dashboard-hide-number', { clear = true }),
  pattern = 'dashboard',
  callback = function(ev)
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.cursorline = false
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})

-- Tự mở lại dashboard khi đóng hết buffer có file (vd: :bd từng buffer,
-- :%bd) mà chưa thoát Neovim — không tính buffer unlisted như dashboard/terminal.
-- Đóng buffer cuối cùng còn lại thường khiến Neovim tự tạo 1 buffer scratch
-- trống ([No Name]) để lấp chỗ window, và buffer đó vẫn buflisted nên đếm
-- #listed không bao giờ về 0 — phải nhận diện riêng case này.
vim.api.nvim_create_autocmd('BufDelete', {
  group = vim.api.nvim_create_augroup('dashboard-reopen-on-empty', { clear = true }),
  callback = function()
    vim.schedule(function()
      local listed = vim.tbl_filter(
        function(buf) return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted end,
        vim.api.nvim_list_bufs()
      )
      if #listed == 0 then
        vim.cmd 'Dashboard'
        return
      end
      if #listed == 1 then
        local buf = listed[1]
        local is_empty_scratch = vim.bo[buf].buftype == ''
          and vim.api.nvim_buf_get_name(buf) == ''
          and not vim.bo[buf].modified
          and vim.bo[buf].filetype ~= 'dashboard'
        if is_empty_scratch then
          -- Bỏ listed thay vì xoá hẳn buffer: force-delete ngay sau khi mở
          -- Dashboard từng đụng vào render nội bộ của dashboard-nvim
          -- (hyper.lua) và gây crash loop
          vim.bo[buf].buflisted = false
          vim.cmd 'Dashboard'
        end
      end
    end)
  end,
})
