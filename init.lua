-- Kiểm tra Neovim đang chạy trong VSCode (do vscode-neovim extension set)
local is_vscode = vim.g.vscode ~= nil

-- ============================================================
-- SECTION 1: FOUNDATION — Cài đặt cơ bản
-- ============================================================
do
  if vim.loader and vim.loader.enable then vim.loader.enable() end

  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '
  vim.g.have_nerd_font = false -- đổi thành true nếu dùng Nerd Font

  -- True color chỉ cần ở terminal; VSCode tự quản lý màu
  if not is_vscode then vim.o.termguicolors = true end

  -- [[ Options ]]
  vim.o.number = true
  vim.o.relativenumber = true
  vim.o.mouse = 'a'
  vim.o.showmode = false
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
  vim.o.breakindent = true
  vim.o.undofile = true       -- lưu lịch sử undo sau khi đóng file
  vim.o.ignorecase = true
  vim.o.smartcase = true
  vim.o.signcolumn = 'yes'
  vim.o.updatetime = 250
  vim.o.timeoutlen = 300
  vim.o.splitright = true
  vim.o.splitbelow = true
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
  vim.o.inccommand = 'split'  -- xem trước kết quả :s/... theo thời gian thực
  vim.o.cursorline = true
  vim.o.scrolloff = 10
  vim.o.confirm = true

  -- Xóa highlight tìm kiếm khi bấm Esc ở normal mode
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Cấu hình diagnostic (lỗi/warning từ LSP)
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },
    virtual_text = true,
    virtual_lines = false,
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float { bufnr = bufnr, scope = 'cursor', focus = false }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Mở danh sách diagnostic' })

  -- ### KEYMAPS CHUNG (terminal + VSCode)

  -- Di chuyển theo visual line — j/k không bỏ qua wrapped text
  -- Khi có count (5j, 10k) thì vẫn dùng j/k thật để nhảy đúng số dòng
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

  -- Nhảy paragraph và căn giữa màn hình
  vim.keymap.set('n', '}', '}zz', { desc = 'Paragraph kế (center)' })
  vim.keymap.set('n', '{', '{zz', { desc = 'Paragraph trước (center)' })

  -- Ngắt dòng tại cursor, không vào insert mode
  vim.keymap.set('n', 'B', 'i<CR><Esc>', { desc = 'Ngắt dòng tại cursor' })

  -- ### BUFFER
  vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Buffer trước' })
  vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Buffer tiếp' })
  vim.keymap.set('n', '<leader>bq', '<cmd>bdelete<CR>', { desc = '[B]uffer đóng' })
  vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', { desc = '[B]uffer mới' })
  vim.keymap.set('n', '<leader>by', '<cmd>%y+<CR>', { desc = '[B]uffer yank toàn bộ' })

  -- Lưu file từ cả insert lẫn normal mode
  vim.keymap.set('i', '<C-s>', '<cmd>w<CR><Esc>', { desc = 'Lưu file' })
  vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { desc = 'Lưu file' })

  -- ### INDENT / MOVE LINES

  -- Visual mode: giữ nguyên selection sau khi indent
  vim.keymap.set('v', '<tab>', '>gv', { desc = 'Tăng indent' })
  vim.keymap.set('v', '<S-tab>', '<gv', { desc = 'Giảm indent' })

  -- Di chuyển dòng trong visual mode (C-j/k không conflict vì window nav ở normal mode)
  vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Dời dòng xuống' })
  vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Dời dòng lên' })

  -- Normal mode dùng Alt để không conflict với C-j/k (window nav ở terminal)
  vim.keymap.set('n', '<A-j>', '<cmd>m .+1<CR>==', { desc = 'Dời dòng xuống' })
  vim.keymap.set('n', '<A-k>', '<cmd>m .-2<CR>==', { desc = 'Dời dòng lên' })

  -- ### SPLITS
  vim.keymap.set('n', '<leader>v', '<cmd>vsplit<CR>', { desc = 'Split dọc' })
  vim.keymap.set('n', '<leader>S', '<cmd>split<CR>', { desc = 'Split ngang' })

  -- ### PASTE OVER TEXT OBJECTS
  -- Thay thế nội dung bên trong/xung quanh text object bằng clipboard
  -- Ví dụ: <leader>piq → paste vào trong cặp nháy gần nhất
  vim.keymap.set('n', '<leader>piq', 'viqp', { desc = 'Paste inside quote' })
  vim.keymap.set('n', '<leader>paq', 'vaqp', { desc = 'Paste around quote' })
  vim.keymap.set('n', '<leader>piB', 'viB"_dP', { desc = 'Paste inside {}' })
  vim.keymap.set('n', '<leader>paB', 'vaB"_dP', { desc = 'Paste around {}' })
  vim.keymap.set('n', '<leader>pib', 'vib"_dP', { desc = 'Paste inside ()' })
  vim.keymap.set('n', '<leader>pab', 'vab"_dP', { desc = 'Paste around ()' })
  vim.keymap.set('n', '<leader>pit', 'vit"_dP', { desc = 'Paste inside tag' })
  vim.keymap.set('n', '<leader>pat', 'vat"_dP', { desc = 'Paste around tag' })

  -- Misc
  vim.keymap.set('n', '<leader>n', '<cmd>nohlsearch<CR>', { desc = 'Tắt highlight tìm kiếm' })
  vim.keymap.set('n', '<leader>y', '<cmd>registers<CR>', { desc = 'Xem registers' })

  -- Cập nhật plugin: :PackUpdate (chỉ terminal)
  if not is_vscode then
    vim.api.nvim_create_user_command('PackUpdate', function()
      local ok, err = pcall(function() vim.pack.update(nil, { offline = false }) end)
      if not ok then vim.notify(('PackUpdate thất bại: %s'):format(err), vim.log.levels.ERROR) end
    end, { desc = 'Cập nhật plugin qua vim.pack' })
  end

  -- Thoát terminal mode bằng Esc Esc (mặc định phải dùng C-\ C-n)
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Thoát terminal mode' })

  -- File explorer: netrw ở terminal, sidebar ở VSCode (Section 9)
  if not is_vscode then
    vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>', { desc = 'Mở/đóng file explorer' })
  end

  -- ### WINDOW NAVIGATION (chỉ terminal)
  -- VSCode: C-j/k dùng để move lines; focus pane dùng <leader>w ở Section 9
  if not is_vscode then
    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Focus cửa sổ trái' })
    vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Focus cửa sổ phải' })
    vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Focus cửa sổ dưới' })
    vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Focus cửa sổ trên' })
  end

  -- Highlight vùng text vừa yank
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight khi yank',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- SECTION 2: PLUGIN MANAGER — vim.pack (chỉ terminal)
-- ============================================================
if not is_vscode then do
  -- vim.pack: plugin manager tích hợp sẵn trong Neovim
  -- Cập nhật:        :lua vim.pack.update()
  -- Xem trạng thái:  :lua vim.pack.update(nil, { offline = true })
  -- Cập nhật nhanh:  :PackUpdate

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'Không có output.' end
      vim.notify(('Build thất bại cho %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- Chạy build step sau khi plugin được cài/cập nhật
  vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
      local name = ev.data.spec.name
      local kind = ev.data.kind
      if kind ~= 'install' and kind ~= 'update' then return end
      if not name then return end

      if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
        run_build(name, { 'make' }, ev.data.path)
        return
      end

      if name == 'LuaSnip' then
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then
          run_build(name, { 'make', 'install_jsregexp' }, ev.data.path)
        end
        return
      end

      if name == 'nvim-treesitter' then
        if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
        vim.cmd 'TSUpdate'
        return
      end
    end,
  })
end end

-- Helper rút gọn URL GitHub
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- mini.nvim + guess-indent: chạy ở cả 2 môi trường
-- Phần còn lại: chỉ terminal
-- ============================================================
do
  -- Tự động nhận dạng indentation của file
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- mini.nvim: text objects và surround — hoạt động ở cả terminal lẫn VSCode
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- ### MINI.AI — TEXT OBJECTS MỞ RỘNG
  -- va)   → chọn xung quanh )
  -- yiiq  → yank trong quote
  -- ci'   → thay đổi trong '
  -- aa/ii → around/inside next object
  require('mini.ai').setup {
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- ### MINI.SURROUND
  -- saiw) → thêm () quanh word
  -- sd'   → xóa ''
  -- sr)'  → thay ) bằng '
  require('mini.surround').setup()

  if not is_vscode then
    if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end

    -- Ký hiệu git ở gutter (thêm/xóa/sửa dòng)
    vim.pack.add { gh 'lewis6991/gitsigns.nvim' }
    require('gitsigns').setup {
      signs = {
        add = { text = '+' }, ---@diagnostic disable-line: missing-fields
        change = { text = '~' }, ---@diagnostic disable-line: missing-fields
        delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
        topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
        changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
      },
    }

    -- Hiển thị gợi ý phím khi bấm leader
    vim.pack.add { gh 'folke/which-key.nvim' }
    require('which-key').setup {
      delay = 0,
      plugins = { spelling = true, presets = {} },
      show_help = false,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
        { '<leader>s', hidden = false, mode = { 'n', 'v' } },
      },
    }

    -- Colorscheme: tokyonight-night
    -- Đổi theme: thay 'tokyonight-night' → storm / moon / day
    vim.pack.add { gh 'folke/tokyonight.nvim' }
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup { styles = { comments = { italic = false } } }
    vim.cmd.colorscheme 'tokyonight-night'

    -- Highlight TODO, NOTE, FIXME, HACK, WARN trong comment
    vim.pack.add { gh 'folke/todo-comments.nvim' }
    require('todo-comments').setup { signs = false }

    -- ### FLASH.NVIM — NHẢY NHANH (thay thế vim-sneak + vim-easymotion)
    -- s{2 ký tự}   → nhảy đến vị trí khớp trong file (sneak)
    -- S            → chọn node treesitter xung quanh cursor
    -- r (operator) → remote flash, vd: yr{ab} để yank từ xa
    -- <leader>.    → fuzzy jump kiểu easymotion
    vim.pack.add { gh 'folke/flash.nvim' }
    require('flash').setup {
      modes = {
        search = { enabled = false }, -- không override / và ?
        char = { enabled = false },   -- không override f/t/F/T
      },
    }
    vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
    vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter' })
    vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Flash remote operator' })
    vim.keymap.set({ 'n', 'x' }, '<leader>.', function() require('flash').jump { search = { mode = 'fuzzy' } } end, { desc = 'Flash fuzzy jump' })

    -- Statusline tối giản
    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function() return '%2l:%-2v' end
  end
end

-- ============================================================
-- SECTION 4: SEARCH & NAVIGATION — Telescope (chỉ terminal)
-- ============================================================
if not is_vscode then do
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then
    table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim')
  end
  vim.pack.add(telescope_plugins)

  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- ### TELESCOPE KEYMAPS
  -- Trong cửa sổ Telescope: <C-/> (insert) hoặc ? (normal) để xem toàn bộ keymaps
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch từ dưới cursor' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch file gần đây' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = 'Tìm buffer đang mở' })
  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch file [N]eovim config' })

  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = 'Tìm kiếm mờ trong buffer hiện tại' })

  vim.keymap.set('n', '<leader>s/', function()
    builtin.live_grep { grep_open_files = true, prompt_title = 'Grep trong các file đang mở' }
  end, { desc = '[S]earch trong file đang mở' })

  -- Gán LSP pickers tự động khi LSP attach vào buffer
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf
      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Document Symbols' })
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Workspace Symbols' })
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })
end end

-- ============================================================
-- SECTION 5: LSP — Language Server Protocol (chỉ terminal)
-- ============================================================
if not is_vscode then do
  -- fidget: hiển thị tiến trình LSP ở góc màn hình
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- ### LSP KEYMAPS
      map('grn', vim.lsp.buf.rename, 'Đổi tên symbol')
      map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
      map('gd', vim.lsp.buf.definition, 'Goto definition')
      map('gk', vim.lsp.buf.hover, 'Hover documentation')
      map('grD', vim.lsp.buf.declaration, 'Goto declaration')

      -- Highlight tất cả references của symbol dưới cursor
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method('textDocument/documentHighlight', event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })
        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- Toggle inlay hints nếu LSP hỗ trợ
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
        end, 'Toggle Inlay Hints')
      end
    end,
  })

  -- Danh sách LSP servers — Mason sẽ tự cài khi khởi động
  -- Thêm/xóa server theo nhu cầu của project
  ---@type table<string, vim.lsp.Config>
  local servers = {
    ts_ls = {},   -- TypeScript / JavaScript
    eslint = {},  -- Linting JS/TS
    stylua = {},  -- Formatter Lua (dùng bởi conform.nvim)
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config'
            and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
          then
            return
          end
        end
        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = { version = 'LuaJIT', path = { 'lua/?.lua', 'lua/?/init.lua' } },
          workspace = {
            checkThirdParty = false,
            library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
              '${3rd}/luv/library',
              '${3rd}/busted/library',
            }),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = { Lua = { format = { enable = false } } },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  require('mason').setup {}

  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- Thêm tool khác nếu cần, vd: 'prettier', 'black', 'pyright'
  })
  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end end

-- ============================================================
-- SECTION 6: FORMATTING — conform.nvim (chỉ terminal)
-- ============================================================
if not is_vscode then do
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Bật autoformat khi lưu theo filetype (bỏ comment để bật):
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end
    end,
    default_format_opts = {
      lsp_format = 'fallback', -- dùng formatter ngoài, fallback về LSP nếu không có
    },
    formatters_by_ft = {
      typescript = { 'prettierd' },
      javascriptreact = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      json = { 'prettierd' },
      css = { 'prettierd' },
      html = { 'prettierd' },
    },
  }

  -- ### FORMAT KEYMAP
  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end end

-- ============================================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS — blink.cmp + LuaSnip (chỉ terminal)
-- ============================================================
if not is_vscode then do
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- Bỏ comment để dùng friendly-snippets (snippet có sẵn cho nhiều ngôn ngữ):
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      -- ### BLINK.CMP KEYMAPS (preset: 'default')
      -- <C-y>         → chấp nhận completion
      -- <C-space>     → mở menu / mở docs
      -- <C-n> / <C-p> → item tiếp / trước
      -- <C-e>         → đóng menu
      -- <C-k>         → toggle signature help
      -- <tab>/<S-tab> → di chuyển trong snippet
      preset = 'default',
    },
    appearance = { nerd_font_variant = 'mono' },
    completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
    sources = { default = { 'lsp', 'path', 'snippets' } },
    snippets = { preset = 'luasnip' },
    fuzzy = { implementation = 'lua' },
    signature = { enabled = true },
  }
end end

-- ============================================================
-- SECTION 8: TREESITTER — syntax highlighting (chỉ terminal)
-- ============================================================
if not is_vscode then do
  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Parser cơ bản được cài sẵn; các parser khác tự cài khi mở file
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    if not vim.treesitter.language.add(language) then return end
    vim.treesitter.start(buf, language)

    -- Bỏ comment để bật treesitter-based folds:
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    -- vim.wo.foldmethod = 'expr'

    local has_indent_query = vim.treesitter.query.get(language, 'indents') ~= nil
    if has_indent_query then vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()" end
  end

  local available_parsers = require('nvim-treesitter').get_available()
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
      local buf, filetype = args.buf, args.match
      local language = vim.treesitter.language.get_lang(filetype)
      if not language then return end

      local installed_parsers = require('nvim-treesitter').get_installed 'parsers'
      if vim.tbl_contains(installed_parsers, language) then
        treesitter_try_attach(buf, language)
      elseif vim.tbl_contains(available_parsers, language) then
        require('nvim-treesitter').install(language):await(function() treesitter_try_attach(buf, language) end)
      else
        treesitter_try_attach(buf, language)
      end
    end,
  })
end end

-- ============================================================
-- SECTION 9: VSCODE-SPECIFIC KEYMAPS
-- Port từ vscodevim → vscode-neovim. Dùng vscode.action() để
-- gọi VSCode commands thay vì Telescope / LSP / neovim built-ins.
-- ============================================================
if is_vscode then
  local vscode = require 'vscode'
  local function act(cmd) return function() vscode.action(cmd) end end

  -- ### FILE & SEARCH
  vim.keymap.set('n', '<C-p>', act 'workbench.action.quickOpen', { desc = 'Quick Open file' })
  vim.keymap.set('n', '<C-f>', act 'actions.find', { desc = 'Tìm trong file hiện tại' })
  vim.keymap.set('n', '<leader>sf', act 'workbench.action.quickOpen', { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sg', act 'workbench.action.findInFiles', { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader><leader>', act 'workbench.action.showAllEditors', { desc = 'Tìm editor đang mở' })
  vim.keymap.set('n', '<leader>/', act 'fuzzySearch.activeTextEditor', { desc = 'Fuzzy search trong file' })
  vim.keymap.set('v', '<leader>/', act 'fuzzySearch.activeTextEditorWithCurrentSelection', { desc = 'Fuzzy search selection' })

  -- Find It Faster (yêu cầu: fzf + rg + bat trên PATH)
  vim.keymap.set('n', '<leader>ff', act 'find-it-faster.findFiles', { desc = '[F]ind [F]iles (fzf)' })
  vim.keymap.set('n', '<leader>fF', act 'find-it-faster.findFilesWithType', { desc = '[F]ind Files + filetype' })
  vim.keymap.set('n', '<leader>fs', act 'find-it-faster.findWithinFiles', { desc = '[F]ind within files' })
  vim.keymap.set('n', '<leader>fS', act 'find-it-faster.findWithinFilesWithType', { desc = '[F]ind within files + type' })

  -- ### LSP / CODE ACTIONS
  -- g-prefix (giống vscodevim cũ)
  vim.keymap.set('n', 'gd', act 'editor.action.revealDefinition', { desc = 'Goto definition' })
  vim.keymap.set('n', 'gp', act 'editor.action.peekDefinition', { desc = 'Peek definition' })
  vim.keymap.set('n', 'gD', act 'editor.action.revealDeclaration', { desc = 'Goto declaration' })
  vim.keymap.set('n', 'gr', act 'editor.action.goToReferences', { desc = 'Goto references' })
  vim.keymap.set('n', 'gR', act 'references-view.find', { desc = 'References panel' })
  vim.keymap.set('n', 'gi', act 'editor.action.goToImplementation', { desc = 'Goto implementation' })
  vim.keymap.set('n', 'gt', act 'editor.action.peekTypeDefinition', { desc = 'Peek type definition' })
  vim.keymap.set('n', 'gs', act 'workbench.action.gotoSymbol', { desc = 'Document symbols' })
  vim.keymap.set('n', 'gS', act 'workbench.action.showAllSymbols', { desc = 'Workspace symbols' })
  vim.keymap.set('n', 'gk', act 'editor.action.showHover', { desc = 'Hover docs' })
  vim.keymap.set('n', 'gf', act 'fuzzySearch.activeTextEditor', { desc = 'Fuzzy search' })

  -- gr-prefix (kickstart-style aliases)
  vim.keymap.set('n', 'grr', act 'editor.action.goToReferences', { desc = '[G]oto [R]eferences' })
  vim.keymap.set('n', 'grd', act 'editor.action.revealDefinition', { desc = '[G]oto [D]efinition' })
  vim.keymap.set('n', 'gri', act 'editor.action.goToImplementation', { desc = '[G]oto [I]mplementation' })
  vim.keymap.set('n', 'grt', act 'editor.action.goToTypeDefinition', { desc = '[G]oto [T]ype Definition' })
  vim.keymap.set('n', 'grn', act 'editor.action.rename', { desc = 'Rename' })
  vim.keymap.set({ 'n', 'x' }, 'gra', act 'editor.action.quickFix', { desc = 'Code action' })
  vim.keymap.set('n', 'grD', act 'editor.action.revealDeclaration', { desc = '[G]oto [D]eclaration' })

  -- ### FORMAT & DIAGNOSTICS
  vim.keymap.set({ 'n', 'v' }, '<leader>f', act 'editor.action.formatDocument', { desc = 'Format document' })
  vim.keymap.set('n', '<leader>q', act 'workbench.actions.view.problems', { desc = 'Mở Problems panel' })
  vim.keymap.set('n', '<leader>th', act 'editor.action.inlayHints.toggle', { desc = 'Toggle Inlay Hints' })

  -- ### RENAME / REFACTOR
  vim.keymap.set('n', '<leader>r', act 'editor.action.rename', { desc = 'Rename symbol' })
  vim.keymap.set('v', '<leader>;', act 'editor.action.refactor', { desc = 'Refactor' })

  -- ### BUFFER / EDITOR
  vim.keymap.set('n', '<leader>bq', act 'workbench.action.closeActiveEditor', { desc = '[B]uffer đóng' })
  vim.keymap.set('n', '<leader>bn', act 'workbench.action.files.newUntitledFile', { desc = '[B]uffer mới' })
  vim.keymap.set('n', '<C-m>', act 'workbench.action.editor.changeLanguageMode', { desc = 'Đổi language mode' })

  -- ### SIDEBAR & UI
  vim.keymap.set('n', '<leader>e', act 'workbench.action.toggleSidebarVisibility', { desc = 'Mở/đóng sidebar' })
  vim.keymap.set('n', '<leader>>', act 'workbench.action.showCommands', { desc = 'Command palette' })

  -- ### PANE / WINDOW FOCUS
  -- C-j/C-k ở normal mode → move lines (giống vscodevim cũ)
  -- C-h/C-l → focus pane trái/phải
  -- <leader>w{h,l,k,j} → focus pane theo hướng
  vim.keymap.set('n', '<C-h>', act 'workbench.action.focusLeftGroup', { desc = 'Focus pane trái' })
  vim.keymap.set('n', '<C-l>', act 'workbench.action.focusRightGroup', { desc = 'Focus pane phải' })
  vim.keymap.set('n', '<leader>wh', act 'workbench.action.focusLeftGroup', { desc = '[W]indow trái' })
  vim.keymap.set('n', '<leader>wl', act 'workbench.action.focusRightGroup', { desc = '[W]indow phải' })
  vim.keymap.set('n', '<leader>wk', act 'workbench.action.focusAboveGroup', { desc = '[W]indow trên' })
  vim.keymap.set('n', '<leader>wj', act 'workbench.action.focusBelowGroup', { desc = '[W]indow dưới' })
  vim.keymap.set('n', '<C-j>', act 'editor.action.moveLinesDownAction', { desc = 'Dời dòng xuống' })
  vim.keymap.set('n', '<C-k>', act 'editor.action.moveLinesUpAction', { desc = 'Dời dòng lên' })

  -- ### TERMINAL
  vim.keymap.set('n', '<leader>tf', act 'workbench.action.terminal.focus', { desc = '[T]erminal focus' })
  vim.keymap.set('n', '<leader>tn', act 'workbench.action.terminal.new', { desc = '[T]erminal mới' })
  vim.keymap.set('n', '<leader>tk', act 'workbench.action.terminal.killTerminalAfterUse', { desc = '[T]erminal kill' })

  -- ### GIT
  vim.keymap.set('n', '<leader>gd', act 'git.viewChanges', { desc = '[G]it diff' })
  vim.keymap.set('n', '<leader>ga', act 'git.stageAll', { desc = '[G]it add all' })
  vim.keymap.set('n', '<leader>gc', act 'git.commit', { desc = '[G]it commit' })
  vim.keymap.set('n', '<leader>gp', act 'git.pushTo', { desc = '[G]it push' })
  vim.keymap.set('n', '<leader>gP', act 'git.pullFrom', { desc = '[G]it pull' })
  vim.keymap.set('n', '<leader>gk', act 'git.checkout', { desc = '[G]it checkout' })
  vim.keymap.set('n', '<leader>gu', act 'git.unstage', { desc = '[G]it unstage' })
  vim.keymap.set('n', '<leader>guc', act 'git.undoCommit', { desc = '[G]it undo commit' })
  vim.keymap.set('n', '<leader>goc', act 'git.viewChanges', { desc = '[G]it open changes' })
  vim.keymap.set('n', '<leader>gos', act 'git.viewStagedChanges', { desc = '[G]it open staged' })
  vim.keymap.set('n', '<leader>gcp', act 'git.cherryPick', { desc = '[G]it cherry pick' })
  vim.keymap.set('n', '<leader>gdb', act 'git.deleteBranch', { desc = '[G]it delete branch' })

  -- ### BOOKMARKS (extension: alefragnani.Bookmarks)
  vim.keymap.set('n', '<leader>mt', act 'bookmarks.toggle', { desc = '[M]ark toggle' })
  vim.keymap.set('n', '<leader>me', act 'bookmarks.toggleLabeled', { desc = '[M]ark edit label' })
  vim.keymap.set('n', '<leader>mn', act 'bookmarks.jumpToNext', { desc = '[M]ark next' })
  vim.keymap.set('n', '<leader>mp', act 'bookmarks.jumpToPrevious', { desc = '[M]ark prev' })
  vim.keymap.set('n', '<leader>ml', act 'bookmarks.list', { desc = '[M]ark list (file)' })
  vim.keymap.set('n', '<leader>mL', act 'bookmarks.listFromAllFiles', { desc = '[M]ark list (all)' })
  vim.keymap.set('n', '<leader>mC', act 'bookmarks.clear', { desc = '[M]ark clear' })

  -- ### HARPOON (extension: tobias-z.vscode-harpoon)
  vim.keymap.set('n', '<leader>hp', act 'vscode-harpoon.editorQuickPick', { desc = '[H]arpoon pick' })
  vim.keymap.set('n', '<leader>ha', act 'vscode-harpoon.addEditor', { desc = '[H]arpoon add' })
  vim.keymap.set('n', '<leader>he', act 'vscode-harpoon.editEditors', { desc = '[H]arpoon edit list' })

  -- ### PROJECT MANAGER (extension: alefragnani.project-manager)
  vim.keymap.set('n', '<leader>pl', act 'projectManager.listProjectsNewWindow', { desc = '[P]roject list (new window)' })
  vim.keymap.set('n', '<leader>pL', act 'projectManager.listProjects', { desc = '[P]roject list' })
  vim.keymap.set('n', '<leader>pe', act 'projectManager.editProjects', { desc = '[P]roject edit' })
  vim.keymap.set('n', '<leader>pr', act 'projectManager.refreshProjects', { desc = '[P]roject refresh' })

  -- ### SETTINGS
  vim.keymap.set('n', '<leader>su', act 'workbench.action.openSettings', { desc = '[S]ettings UI' })
  vim.keymap.set('n', '<leader>sj', act 'workbench.action.openSettingsJson', { desc = '[S]ettings JSON' })
end

-- ============================================================
-- SECTION 10: PLUGINS TÙY CHỌN
-- Bỏ comment để bật; khởi động lại Neovim sau khi thay đổi
-- ============================================================
do
  -- require 'kickstart.plugins.debug'        -- DAP debugger
  -- require 'kickstart.plugins.indent_line'  -- indent guides
  -- require 'kickstart.plugins.lint'         -- linter
  -- require 'kickstart.plugins.autopairs'    -- tự đóng ngoặc
  -- require 'kickstart.plugins.neo-tree'     -- file explorer nâng cao
  -- require 'kickstart.plugins.gitsigns'     -- git keymaps đầy đủ

  -- Plugin tùy chỉnh cá nhân:
  -- require 'custom.plugins'
end

-- vim: ts=2 sts=2 sw=2 et
