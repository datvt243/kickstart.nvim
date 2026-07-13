-- codesnap.nvim: chụp đoạn code đang chọn thành ảnh đẹp, giống VSCode CodeSnap (terminal only)
-- https://github.com/mistricky/codesnap.nvim
-- Keymap nổi bật: <leader>cp copy ảnh vào clipboard, <leader>cP lưu ảnh ra file (visual mode)
if vim.g.vscode ~= nil then return end

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'mistricky/codesnap.nvim' }

-- Windows workarounds — must run BEFORE require('codesnap').setup{}, since both
-- bugs below are hit during module load, not lazily:
-- 1) codesnap/utils/path.lua's dir_name() derives the plugin's own folder from
--    debug.getinfo(1).source, matching only "\" as a path separator. Neovim on
--    Windows reports that source with "/", so the match returns nil and
--    codesnap/module.lua:15 crashes concatenating nil (breaks on require, before
--    any command runs). Fix: resolve the folder via nvim_get_runtime_file instead.
-- 2) codesnap/config.lua always calls module.load_generator(true), which looks
--    for a locally cargo-built debug binary (generator/target/debug/generator.dll)
--    instead of the prebuilt release lib codesnap.nvim auto-downloads from GitHub
--    Releases. Without a local Rust/cargo/MSVC toolchain this throws "Failed to
--    load the generator library" on every :CodeSnap/:CodeSnapSave. Fix: ignore
--    the debug flag and always use the downloaded prebuilt lib.
if vim.fn.has 'win32' == 1 then
  local ok_path, path_utils = pcall(require, 'codesnap.utils.path')
  if ok_path then
    local utils_file = vim.api.nvim_get_runtime_file('lua/codesnap/utils/path.lua', false)[1]
    local utils_dir = utils_file and vim.fn.fnamemodify(utils_file, ':h')
    if utils_dir then path_utils.with_dir_name = function(path) return utils_dir .. '/' .. path end end
  end

  local ok_module, codesnap_module = pcall(require, 'codesnap.module')
  if ok_module then
    local load_generator = codesnap_module.load_generator
    codesnap_module.load_generator = function(_) return load_generator(false) end
  end
end

require('codesnap').setup {}

-- ### CODESNAP KEYMAPS (visual mode)
-- Copy snapshot của selection vào clipboard
vim.keymap.set('x', '<leader>cp', '<cmd>CodeSnap<CR>', { desc = 'CodeSnap: copy ảnh vào clipboard' })
-- Lưu snapshot ra file (nhập đường dẫn)
local default_snapshot_path = vim.fn.has 'win32' == 1 and '~/Desktop/codesnap/snapshot.png' or '~/Desktop/codesnap/snapshot.png'

vim.keymap.set('x', '<leader>cP', function()
  vim.ui.input({
    prompt = 'Lưu snapshot vào: ',
    default = vim.fn.expand(default_snapshot_path),
  }, function(path)
    if path and path ~= '' then
      vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
      vim.cmd('CodeSnapSave ' .. path)
    end
  end)
end, { desc = 'CodeSnap: lưu ảnh ra file' })
