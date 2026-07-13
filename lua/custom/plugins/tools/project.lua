-- project.nvim: tự động detect project root (.git, package.json...) và tích hợp Telescope (terminal only)
-- https://github.com/ahmedkhalf/project.nvim
-- Keymap nổi bật: <leader>sp mở Telescope picker danh sách project — marker ### PROJECT
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'ahmedkhalf/project.nvim' }

require('project_nvim').setup {
  detection_methods = { 'pattern', 'lsp' },
  patterns = { '.git', 'package.json', 'Makefile', '.project' },
  show_hidden = true,
  silent_chdir = true,
}

-- project.nvim đổi cwd bằng lệnh `cd` (scope mặc định 'global') nên sẽ trigger DirChanged —
-- dùng event này để tự đóng buffer cũ khi chuyển project, dù chuyển bằng <leader>sp hay
-- tự động detect root khi mở file. Chỉ đóng buffer CHƯA sửa dở để tránh mất dữ liệu; buffer
-- đang có thay đổi chưa lưu sẽ được giữ lại. Không còn buffer nào thì mở lại Dashboard.
vim.api.nvim_create_autocmd('DirChanged', {
  group = vim.api.nvim_create_augroup('project-close-buffers', { clear = true }),
  callback = function(event)
    if event.match ~= 'global' then return end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and not vim.bo[buf].modified then vim.api.nvim_buf_delete(buf, {}) end
    end
    if #vim.fn.getbufinfo { buflisted = 1 } == 0 then vim.cmd 'Dashboard' end
  end,
})

-- ### PROJECT
-- <leader>sp → mở Telescope picker danh sách project
-- Sau khi chọn: cd vào project + mở Neo-tree
vim.keymap.set('n', '<leader>sp', function()
  require('telescope').extensions.projects.projects(require('telescope.themes').get_ivy {
    -- Hiển thị "parent/folder" thay vì chỉ "folder" — hữu ích khi 2 project trùng tên
    -- entry_maker = function(entry)
    --   local folder = vim.fn.fnamemodify(entry, ':t')
    --   local parent = vim.fn.fnamemodify(entry, ':h:t')
    --   return {
    --     value = entry,
    --     display = parent .. '/' .. folder,
    --     ordinal = parent .. '/' .. folder,
    --   }
    -- end,
    attach_mappings = function(_, map)
      map('i', '<CR>', function(prompt_bufnr)
        local entry = require('telescope.actions.state').get_selected_entry()
        require('telescope.actions').close(prompt_bufnr)
        if entry then
          -- fnameescape để path có dấu cách / ký tự đặc biệt (hay gặp trên Windows) không làm hỏng lệnh :cd
          vim.cmd.cd(vim.fn.fnameescape(entry.value))
          vim.cmd 'Neotree reveal'
        end
      end)
      return true
    end,
  })
end, { desc = '[S]earch [P]rojects' })
