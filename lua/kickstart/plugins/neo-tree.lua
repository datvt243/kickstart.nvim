-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim
local plugins = {{
  src = 'https://github.com/nvim-neo-tree/neo-tree.nvim',
  version = vim.version.range '*'
}, 'https://github.com/nvim-lua/plenary.nvim', 'https://github.com/MunifTanjim/nui.nvim'}

if vim.g.have_nerd_font then
  table.insert(plugins, 'https://github.com/nvim-tree/nvim-web-devicons') -- not strictly required, but recommended
end

vim.pack.add(plugins)

vim.keymap.set('n', '\\', '<Cmd>Neotree reveal<CR>', {
  desc = 'NeoTree reveal',
  silent = true
})
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree toggle<CR>', {
  desc = 'Mở/đóng file explorer'
})

-- Tự mở neo-tree khi: không có arg (cùng dashboard) hoặc mở thư mục (nvim .)
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local argc = vim.fn.argc()
    local is_dir = argc == 1 and vim.fn.isdirectory(vim.fn.argv(0)) == 1
    if argc == 0 or is_dir then
      -- defer để dashboard render xong trước
      vim.defer_fn(function()
        vim.cmd 'Neotree show'
      end, 100)
    end
  end
})

require('neo-tree').setup {
  filesystem = {
    window = {
      mappings = {
        ['\\'] = 'close_window'
      }
    }
  }
}
