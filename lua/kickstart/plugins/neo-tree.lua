-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

if vim.g.vscode ~= nil then return end

-- Icon: dùng mini.icons qua mock_nvim_web_devicons() (xem lua/custom/plugins/ui/icons.lua),
-- không cần cài nvim-web-devicons thật
local plugins = {
  {
    src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
    version = vim.version.range '*',
  },
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
}

vim.pack.add(plugins)

-- Focus + reveal file hiện tại trong Neo-tree; nhấn \ lần nữa từ Neo-tree để trả focus về editor
vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', {
  desc = 'NeoTree reveal',
  silent = true,
})
-- Bật/tắt Neo-tree sidebar (không reveal file đang mở)
vim.keymap.set('n', '<leader>et', '<Cmd>Neotree toggle<CR>', {
  desc = '[T]oglle [E]xplorer',
})
-- Focus vào cửa sổ Neo-tree (mở nếu đang đóng), không reveal file hiện tạe
-- Quay lại editor: dùng Ctrl+H (Neo-tree luôn nằm bên trái)
vim.keymap.set('n', '<leader>ee', '<Cmd>Neotree focus<CR>', {
  desc = 'Focus vào Neo-tree',
})

-- Bật/tắt Neo-tree sang source git_status: liệt kê file đã đổi/staged/untracked,
-- giống Source Control panel của VSCode — dùng source có sẵn của neo-tree, không cần plugin khác
vim.keymap.set('n', '<leader>eg', '<Cmd>Neotree toggle git_status<CR>', {
  desc = 'Neo-tree: bật/tắt [G]it status',
})

-- Tự mở neo-tree khi: không có arg (cùng dashboard) hoặc mở thư mục (nvim .)
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('neo-tree-auto-open', {
    clear = true,
  }),
  callback = function()
    local argc = vim.fn.argc()
    local is_dir = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
    if argc == 0 or is_dir then
      -- defer để dashboard render xong trước
      vim.defer_fn(function() vim.cmd 'Neotree show' end, 100)
    end
  end,
})

-- Refresh Neo-tree khi Neovim lấy lại focus (vd: sau khi Claude Code/terminal tạo file bên ngoài)
-- libuv file watcher chỉ theo dõi thư mục đang expand nên đôi khi bỏ sót thay đổi ngoài
vim.api.nvim_create_autocmd('FocusGained', {
  group = vim.api.nvim_create_augroup('neo-tree-focus-refresh', {
    clear = true,
  }),
  callback = function() pcall(vim.cmd, 'Neotree refresh') end,
})

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  filesystem = {
    filtered_items = {
      visible = true,
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    use_libuv_file_watcher = true,
    window = {
      mappings = {
        ['\\'] = function()
          vim.cmd 'wincmd p' -- trả focus về editor, neo-tree vẫn mở
        end,
      },
    },
  },
}

require('neo-tree').setup(config)
