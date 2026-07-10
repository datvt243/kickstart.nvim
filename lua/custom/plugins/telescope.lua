-- Fuzzy finder: Telescope
-- Tìm file, grep toàn project, xem buffer, LSP symbols, git commits...
-- telescope-fzf-native: tăng tốc bằng native C (cần make)
-- telescope-ui-select: dùng Telescope làm UI picker cho vim.ui.select (code actions...)
-- https://github.com/nvim-telescope/telescope.nvim
local function gh(repo)
  return 'https://github.com/' .. repo
end

if vim.g.vscode ~= nil then
  return
end

local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim'
}

if vim.fn.executable 'make' == 1 then
  table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim')
end
vim.pack.add(telescope_plugins)

require('telescope').setup {
  extensions = {
    ['ui-select'] = {require('telescope.themes').get_dropdown()}
  }
}
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'projects')

-- ### TELESCOPE KEYMAPS
-- Trong cửa sổ Telescope: <C-/> (insert) hoặc ? (normal) để xem toàn bộ keymaps
local builtin = require 'telescope.builtin'
-- Tìm kiếm trong Neovim help tags
vim.keymap.set('n', '<leader>sh', builtin.help_tags, {
  desc = '[S]earch [H]elp'
})
-- Tìm kiếm keymap đang active theo tên hoặc phím
vim.keymap.set('n', '<leader>sk', builtin.keymaps, {
  desc = '[S]earch [K]eymaps'
})
-- Tìm file theo tên trong project (tôn trọng .gitignore)
vim.keymap.set('n', '<leader>sf', builtin.find_files, {
  desc = '[S]earch [F]iles'
})
-- Chọn Telescope picker từ danh sách tất cả pickers có sẵn
vim.keymap.set('n', '<leader>ss', builtin.builtin, {
  desc = '[S]earch [S]elect Telescope'
})
-- Grep từ hoặc cụm từ dưới cursor trong toàn project
vim.keymap.set({'n', 'v'}, '<leader>sw', builtin.grep_string, {
  desc = '[S]earch từ dưới cursor'
})
-- Live grep toàn project theo thời gian thực (kết quả cập nhật khi gõ)
vim.keymap.set('n', '<leader>sg', builtin.live_grep, {
  desc = '[S]earch by [G]rep'
})
-- Tìm kiếm trong danh sách lỗi/warning từ LSP
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, {
  desc = '[S]earch [D]iagnostics'
})
-- Mở lại Telescope session trước (giữ nguyên query và kết quả)
vim.keymap.set('n', '<leader>sr', builtin.resume, {
  desc = '[S]earch [R]esume'
})
-- Danh sách file đã mở gần đây (oldfiles)
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, {
  desc = '[S]earch file gần đây'
})
-- Tìm command Neovim theo tên và chạy ngay
vim.keymap.set('n', '<leader>sc', builtin.commands, {
  desc = '[S]earch [C]ommands'
})
-- Chuyển đổi buffer bằng Telescope picker
vim.keymap.set('n', '<leader><leader>', builtin.buffers, {
  desc = 'Tìm buffer đang mở'
})
-- Tìm file trong thư mục config Neovim (~/.config/nvim)
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files {
    cwd = vim.fn.stdpath 'config'
  }
end, {
  desc = '[S]earch file [N]eovim config'
})
-- Fuzzy search trong nội dung buffer hiện tại (dropdown, không có preview)
vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false
  })
end, {
  desc = 'Tìm kiếm mờ trong buffer hiện tại'
})
-- Live grep chỉ trong các file đang mở (buffer đang có)
vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Grep trong các file đang mở'
  }
end, {
  desc = '[S]earch trong file đang mở'
})

-- Gán LSP pickers tự động khi LSP attach vào buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', {
    clear = true
  }),
  callback = function(event)
    local buf = event.buf
    -- Tìm tất cả references của symbol trong Telescope (thay vì quickfix list)
    vim.keymap.set('n', 'grr', builtin.lsp_references, {
      buffer = buf,
      desc = '[G]oto [R]eferences'
    })
    -- Tìm implementations của interface/abstract class trong Telescope
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, {
      buffer = buf,
      desc = '[G]oto [I]mplementation'
    })
    -- Mở definition trong Telescope (thay vì nhảy thẳng như gd)
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, {
      buffer = buf,
      desc = '[G]oto [D]efinition'
    })
    -- Xem tất cả symbols trong file hiện tại (functions, classes, variables...)
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, {
      buffer = buf,
      desc = 'Document Symbols'
    })
    -- Tìm symbol trong toàn workspace (tìm động, cập nhật khi gõ)
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, {
      buffer = buf,
      desc = 'Workspace Symbols'
    })
    -- Mở type definition trong Telescope (kiểu của biến/function)
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, {
      buffer = buf,
      desc = '[G]oto [T]ype Definition'
    })
  end
})
