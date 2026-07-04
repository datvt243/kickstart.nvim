--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

   NOTE: Look for lines like this

    Throughout the file. These are for you, the reader, to help you understand what is happening.
    Feel free to delete them once you know what you're doing, but they should serve as a guide
    for when you are first encountering a few different constructs in your Neovim config.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

-- Detect whether Neovim is embedded inside VSCode (set by vscode-neovim extension).
-- Used throughout to skip terminal-only plugins and load VSCode-specific keymaps instead.
local is_vscode = vim.g.vscode ~= nil

-- ============================================================
-- SECTION 1: FOUNDATION
-- Core Neovim settings, leaders, options, basic keymaps, basic autocmds
-- ============================================================
do
  -- Enable faster startup by caching compiled Lua modules
  if vim.loader and vim.loader.enable then vim.loader.enable() end

  -- Set <space> as the leader key
  -- See `:help mapleader`
  --  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ' '

  -- Set to true if you have a Nerd Font installed and selected in the terminal
  vim.g.have_nerd_font = false

  -- Enable true color; VSCode manages its own colors so skip it there
  if not is_vscode then vim.o.termguicolors = true end

  -- [[ Setting options ]]
  --  See `:help vim.o`
  -- NOTE: You can change these options as you wish!
  --  For more options, you can see `:help option-list`

  -- Make line numbers default
  vim.o.number = true
  vim.o.relativenumber = true

  -- Enable mouse mode, can be useful for resizing splits for example!
  vim.o.mouse = 'a'

  -- Don't show the mode, since it's already in the status line
  vim.o.showmode = false

  -- Sync clipboard between OS and Neovim.
  --  Schedule the setting after `UiEnter` because it can increase startup-time.
  --  Remove this option if you want your OS clipboard to remain independent.
  --  See `:help 'clipboard'`
  vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

  -- Enable break indent
  vim.o.breakindent = true

  -- Enable undo/redo changes even after closing and reopening a file
  vim.o.undofile = true

  -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
  vim.o.ignorecase = true
  vim.o.smartcase = true

  -- Keep signcolumn on by default
  vim.o.signcolumn = 'yes'

  -- Decrease update time
  vim.o.updatetime = 250

  -- Decrease mapped sequence wait time
  vim.o.timeoutlen = 300

  -- Configure how new splits should be opened
  vim.o.splitright = true
  vim.o.splitbelow = true

  -- Sets how neovim will display certain whitespace characters in the editor.
  --  See `:help 'list'`
  --  and `:help 'listchars'`
  vim.o.list = true
  vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

  -- Preview substitutions live, as you type!
  vim.o.inccommand = 'split'

  -- Show which line your cursor is on
  vim.o.cursorline = true

  -- Minimal number of screen lines to keep above and below the cursor.
  vim.o.scrolloff = 10

  -- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
  -- instead raise a dialog asking if you wish to save the current file(s)
  -- See `:help 'confirm'`
  vim.o.confirm = true

  -- [[ Basic Keymaps ]]
  --  See `:help vim.keymap.set()`

  -- Clear highlights on search when pressing <Esc> in normal mode
  --  See `:help hlsearch`
  vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

  -- Diagnostic Config & Keymaps
  --  See `:help vim.diagnostic.Opts`
  vim.diagnostic.config {
    update_in_insert = false,
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = { severity = { min = vim.diagnostic.severity.WARN } },

    -- Can switch between these as you prefer
    virtual_text = true, -- Text shows up at the end of the line
    virtual_lines = false, -- Text shows up underneath the line, with virtual lines

    -- Auto open the float, so you can easily read the errors when jumping with `[d` and `]d`
    jump = {
      on_jump = function(_, bufnr)
        vim.diagnostic.open_float {
          bufnr = bufnr,
          scope = 'cursor',
          focus = false,
        }
      end,
    },
  }

  vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

  -- [[ Common Keymaps — hoạt động ở cả terminal và VSCode ]]

  -- Visual-line movement: j/k không skip wrapped lines, nhưng vẫn giữ behavior khi có count (5j, 10k)
  vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
  vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

  -- Căn giữa màn hình sau khi nhảy paragraph
  vim.keymap.set('n', '}', '}zz', { desc = 'Next paragraph (centered)' })
  vim.keymap.set('n', '{', '{zz', { desc = 'Prev paragraph (centered)' })

  -- Break line tại vị trí cursor mà không cần vào insert mode
  vim.keymap.set('n', 'B', 'i<CR><Esc>', { desc = 'Break line at cursor' })

  -- Buffer navigation
  vim.keymap.set('n', '<S-h>', '<cmd>bprevious<CR>', { desc = 'Prev buffer' })
  vim.keymap.set('n', '<S-l>', '<cmd>bnext<CR>', { desc = 'Next buffer' })
  vim.keymap.set('n', '<leader>bq', '<cmd>bdelete<CR>', { desc = '[B]uffer [Q]uit' })
  vim.keymap.set('n', '<leader>bn', '<cmd>enew<CR>', { desc = '[B]uffer [N]ew' })
  vim.keymap.set('n', '<leader>by', '<cmd>%y+<CR>', { desc = '[B]uffer [Y]ank all' })

  -- Save từ insert và normal mode
  vim.keymap.set('i', '<C-s>', '<cmd>w<CR><Esc>', { desc = 'Save file' })
  vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', { desc = 'Save file' })

  -- Indent/outdent: visual mode giữ nguyên selection sau khi indent
  vim.keymap.set('v', '<tab>', '>gv', { desc = 'Indent selection' })
  vim.keymap.set('v', '<S-tab>', '<gv', { desc = 'Outdent selection' })

  -- Move lines: visual mode dùng C-j/C-k (không conflict vì window nav chỉ ở normal mode)
  vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { silent = true, desc = 'Move lines down' })
  vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { silent = true, desc = 'Move lines up' })

  -- Move line ở normal mode: dùng Alt thay vì Ctrl để không conflict với window nav
  vim.keymap.set('n', '<A-j>', '<cmd>m .+1<CR>==', { desc = 'Move line down' })
  vim.keymap.set('n', '<A-k>', '<cmd>m .-2<CR>==', { desc = 'Move line up' })

  -- Splits
  vim.keymap.set('n', '<leader>v', '<cmd>vsplit<CR>', { desc = '[V]ertical split' })
  vim.keymap.set('n', '<leader>S', '<cmd>split<CR>', { desc = '[S]plit horizontal' })

  -- Misc
  vim.keymap.set('n', '<leader>n', '<cmd>nohlsearch<CR>', { desc = '[N]o highlight search' })
  vim.keymap.set('n', '<leader>y', '<cmd>registers<CR>', { desc = 'Show [Y]ank registers' })

  -- Paste over text objects (thay thế nội dung bên trong bằng clipboard)
  -- Ví dụ: <leader>piq → thay thế nội dung trong dấu nháy gần nhất
  vim.keymap.set('n', '<leader>piq', 'viqp', { desc = 'Paste inside quote' })
  vim.keymap.set('n', '<leader>paq', 'vaqp', { desc = 'Paste around quote' })
  vim.keymap.set('n', '<leader>piB', 'viB"_dP', { desc = 'Paste inside {}' })
  vim.keymap.set('n', '<leader>paB', 'vaB"_dP', { desc = 'Paste around {}' })
  vim.keymap.set('n', '<leader>pib', 'vib"_dP', { desc = 'Paste inside ()' })
  vim.keymap.set('n', '<leader>pab', 'vab"_dP', { desc = 'Paste around ()' })
  vim.keymap.set('n', '<leader>pit', 'vit"_dP', { desc = 'Paste inside tag' })
  vim.keymap.set('n', '<leader>pat', 'vat"_dP', { desc = 'Paste around tag' })

  -- Manual plugin update command (works with vim.pack, terminal only)
  -- Run: :PackUpdate
  if not is_vscode then
    vim.api.nvim_create_user_command('PackUpdate', function()
      local ok, err = pcall(function()
        vim.pack.update(nil, { offline = false })
      end)
      if not ok then
        vim.notify(('PackUpdate failed: %s'):format(err), vim.log.levels.ERROR)
      end
    end, { desc = 'Update plugins via vim.pack (online)' })
  end

  -- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
  -- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
  -- is not what someone will guess without a bit more experience.
  --
  -- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
  -- or just use <C-\><C-n> to exit terminal mode
  vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

  -- File explorer toggle
  -- Terminal: netrw built-in | VSCode: sidebar (mapped in Section 9)
  if not is_vscode then
    vim.keymap.set('n', '<leader>e', '<cmd>Lexplore<CR>', { desc = 'Toggle file [E]xplorer' })
  end

  -- Keybinds to make split navigation easier.
  --  Use CTRL+<hjkl> to switch between windows
  --
  --  See `:help wincmd` for a list of all window commands
  --
  -- NOTE: In VSCode, <C-j>/<C-k> are used for moving lines (matching user's vscodevim setup).
  -- Pane focus in VSCode is handled via <leader>w prefix in Section 9.
  if not is_vscode then
    vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
    vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
    vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
    vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
  end

  -- [[ Basic Autocommands ]]
  --  See `:help lua-guide-autocommands`

  -- Highlight when yanking (copying) text
  --  Try it with `yap` in normal mode
  --  See `:help vim.hl.on_yank()`
  vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
  })
end

-- ============================================================
-- SECTION 2: PLUGIN MANAGER INTRO
-- vim.pack intro, build hooks — terminal only
-- ============================================================
if not is_vscode then do
  -- [[ Intro to `vim.pack` ]]
  -- `vim.pack` is a new plugin manager built into Neovim,
  --  which provides a Lua interface for installing and managing plugins.
  --
  --  See `:help vim.pack`, `:help vim.pack-examples` or the
  --  excellent blog post from the creator of vim.pack and mini.nvim:
  --  https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack
  --
  --  To inspect plugin state and pending updates, run
  --    :lua vim.pack.update(nil, { offline = true })
  --
  --  To update plugins, run
  --    :lua vim.pack.update()

  local function run_build(name, cmd, cwd)
    local result = vim.system(cmd, { cwd = cwd }):wait()
    if result.code ~= 0 then
      local stderr = result.stderr or ''
      local stdout = result.stdout or ''
      local output = stderr ~= '' and stderr or stdout
      if output == '' then output = 'No output from build command.' end
      vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
    end
  end

  -- This autocommand runs after a plugin is installed or updated and
  --  runs the appropriate build command for that plugin if necessary.
  --
  -- See `:help vim.pack-events`
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
        if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
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

---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.
---@param repo string
---@return string
local function gh(repo) return 'https://github.com/' .. repo end

-- ============================================================
-- SECTION 3: UI / CORE UX PLUGINS
-- guess-indent and mini.nvim run in BOTH environments.
-- gitsigns, which-key, colorscheme, todo-comments, statusline are terminal-only.
-- ============================================================
do
  -- guess-indent: auto-detect indentation — works fine everywhere
  vim.pack.add { gh 'NMAC427/guess-indent.nvim' }
  require('guess-indent').setup {}

  -- mini.nvim: text objects (mini.ai) and surround (mini.surround) are pure
  -- motion-layer plugins that work identically in terminal and VSCode.
  vim.pack.add { gh 'nvim-mini/mini.nvim' }

  -- Better Around/Inside textobjects
  --
  -- Examples:
  --  - va)  - [V]isually select [A]round [)]paren
  --  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
  --  - ci'  - [C]hange [I]nside [']quote
  require('mini.ai').setup {
    -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
    mappings = {
      around_next = 'aa',
      inside_next = 'ii',
    },
    n_lines = 500,
  }

  -- Add/delete/replace surroundings (brackets, quotes, etc.)
  --
  -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
  -- - sd'   - [S]urround [D]elete [']quotes
  -- - sr)'  - [S]urround [R]eplace [)] [']
  require('mini.surround').setup()

  -- The rest of this section is terminal-only UI
  if not is_vscode then
    if vim.g.have_nerd_font then vim.pack.add { gh 'nvim-tree/nvim-web-devicons' } end

    -- Here is a more advanced configuration example that passes options to `gitsigns.nvim`
    --
    -- See `:help gitsigns` to understand what each configuration key does.
    -- Adds git related signs to the gutter, as well as utilities for managing changes
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

    -- Useful plugin to show you pending keybinds.
    vim.pack.add { gh 'folke/which-key.nvim' }
    require('which-key').setup {
      -- Delay between pressing a key and opening which-key (milliseconds)
      delay = 0,
      plugins = {
        spelling = true,
        presets = {},
      },
      show_help = false,
      icons = { mappings = vim.g.have_nerd_font },
      -- Document existing key chains
      spec = {
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
        { '<leader>s', hidden = false, mode = { 'n', 'v' } },
      },
    }

    -- [[ Colorscheme ]]
    -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command under that to load whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    vim.pack.add { gh 'folke/tokyonight.nvim' }
    ---@diagnostic disable-next-line: missing-fields
    require('tokyonight').setup {
      styles = {
        comments = { italic = false },
      },
    }
    vim.cmd.colorscheme 'tokyonight-night'

    -- Highlight todo, notes, etc in comments
    vim.pack.add { gh 'folke/todo-comments.nvim' }
    require('todo-comments').setup { signs = false }

    -- flash.nvim: thay thế vim-sneak (s + 2 ký tự) và vim-easymotion
    -- s{char}{char}  → nhảy đến vị trí khớp với 2 ký tự (sneak mode)
    -- <leader>.      → treesitter-aware search (easymotion-like)
    -- r{char}{char}  → remote flash (dùng trong operator-pending, vd: yr{ab} )
    vim.pack.add { gh 'folke/flash.nvim' }
    require('flash').setup {
      modes = {
        search = { enabled = false }, -- không override / và ? mặc định
        char = {
          -- dùng f/t/F/T thông thường, không override bằng flash
          enabled = false,
        },
      },
    }
    vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump (sneak)' })
    vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter select' })
    vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Flash remote operator' })
    vim.keymap.set({ 'n', 'x' }, '<leader>.', function() require('flash').jump { search = { mode = 'fuzzy' } } end, { desc = 'Flash fuzzy (easymotion-like)' })

    -- Simple and easy statusline.
    local statusline = require 'mini.statusline'
    -- Set `use_icons` to true if you have a Nerd Font
    statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function() return '%2l:%-2v' end

    -- ... and there is more!
    --  Check out: https://github.com/nvim-mini/mini.nvim
  end
end

-- ============================================================
-- SECTION 4: SEARCH & NAVIGATION
-- Telescope setup, keymaps, LSP picker mappings — terminal only
-- ============================================================
if not is_vscode then do
  -- [[ Fuzzy Finder (files, lsp, etc) ]]
  --
  -- Telescope is a fuzzy finder that comes with a lot of different things that
  -- it can fuzzy find! It's more than just a "file finder", it can search
  -- many different aspects of Neovim, your workspace, LSP, and more!
  --
  -- The easiest way to use Telescope, is to start by doing something like:
  --  :Telescope help_tags
  --
  -- Two important keymaps to use while in Telescope are:
  --  - Insert mode: <c-/>
  --  - Normal mode: ?
  --
  -- This opens a window that shows you all of the keymaps for the current
  -- Telescope picker. This is really useful to discover what Telescope can
  -- do as well as how to actually do it!

  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-ui-select.nvim',
  }
  if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

  vim.pack.add(telescope_plugins)

  -- See `:help telescope` and `:help telescope.setup()`
  require('telescope').setup {
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  -- Enable Telescope extensions if they are installed
  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  -- See `:help telescope.builtin`
  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
  vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
  vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

  -- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = function(event)
      local buf = event.buf

      vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
      vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
      vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })
      vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
      vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
      vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
    end,
  })

  -- Override default behavior and theme when searching
  vim.keymap.set('n', '<leader>/', function()
    builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer' })

  vim.keymap.set(
    'n',
    '<leader>s/',
    function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end,
    { desc = '[S]earch [/] in Open Files' }
  )

  vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[S]earch [N]eovim files' })
end end

-- ============================================================
-- SECTION 5: LSP
-- LSP keymaps, server configuration, Mason tools — terminal only
-- ============================================================
if not is_vscode then do
  -- [[ LSP Configuration ]]
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.

  -- Useful status updates for LSP.
  vim.pack.add { gh 'j-hui/fidget.nvim' }
  require('fidget').setup {}

  --  This function gets run when an LSP attaches to a particular buffer.
  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      map('grn', vim.lsp.buf.rename, '[R]e[n]ame')

      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })

      -- Shortcut: gd → definition (mirrors user's vscodevim gd binding)
      map('gd', vim.lsp.buf.definition, '[G]oto [D]efinition (shortcut)')

      -- Show hover documentation (mirrors user's gk binding)
      map('gk', vim.lsp.buf.hover, 'Show hover [K]')

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
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

      -- Toggle inlay hints if the language server supports them
      if client and client:supports_method('textDocument/inlayHint', event.buf) then
        map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --  See `:help lsp-config` for information about keys and how to configure
  ---@type table<string, vim.lsp.Config>
  local servers = {
    ts_ls = {},   -- TypeScript/JavaScript
    eslint = {},  -- Linting

    stylua = {}, -- Used to format Lua code

    -- Special Lua Config, as recommended by neovim help docs
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
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
      settings = {
        Lua = {
          format = { enable = false },
        },
      },
    },
  }

  vim.pack.add {
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }

  -- Automatically install LSPs and related tools to stdpath for Neovim
  require('mason').setup {}

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  local ensure_installed = vim.tbl_keys(servers or {})
  vim.list_extend(ensure_installed, {
    -- You can add other tools here that you want Mason to install
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end
end end

-- ============================================================
-- SECTION 6: FORMATTING
-- conform.nvim setup and keymap — terminal only
-- ============================================================
if not is_vscode then do
  -- [[ Formatting ]]
  vim.pack.add { gh 'stevearc/conform.nvim' }
  require('conform').setup {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- You can specify filetypes to autoformat on save here:
      local enabled_filetypes = {
        -- lua = true,
        -- python = true,
      }
      if enabled_filetypes[vim.bo[bufnr].filetype] then
        return { timeout_ms = 500 }
      else
        return nil
      end
    end,
    default_format_opts = {
      lsp_format = 'fallback',
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

  vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
end end

-- ============================================================
-- SECTION 7: AUTOCOMPLETE & SNIPPETS
-- blink.cmp and luasnip setup — terminal only
-- ============================================================
if not is_vscode then do
  -- [[ Snippet Engine ]]
  vim.pack.add { { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
  require('luasnip').setup {}

  -- `friendly-snippets` contains a variety of premade snippets.
  --    See the README about individual language/framework/plugin snippets:
  --    https://github.com/rafamadriz/friendly-snippets
  --
  -- vim.pack.add { gh 'rafamadriz/friendly-snippets' }
  -- require('luasnip.loaders.from_vscode').lazy_load()

  -- [[ Autocomplete Engine ]]
  vim.pack.add { { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
  require('blink.cmp').setup {
    keymap = {
      -- 'default' (recommended) for mappings similar to built-in completions
      --   <c-y> to accept ([y]es) the completion.
      --    This will auto-import if your LSP supports it.
      --    This will expand snippets if the LSP sent a snippet.
      -- 'super-tab' for tab to accept
      -- 'enter' for enter to accept
      -- 'none' for no mappings
      --
      -- All presets have the following mappings:
      -- <tab>/<s-tab>: move to right/left of your snippet expansion
      -- <c-space>: Open menu or open docs if already open
      -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
      -- <c-e>: Hide menu
      -- <c-k>: Toggle signature help
      --
      -- See `:help blink-cmp-config-keymap` for defining your own keymap
      preset = 'default',
    },

    appearance = {
      nerd_font_variant = 'mono',
    },

    completion = {
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = 'luasnip' },

    fuzzy = { implementation = 'lua' },

    -- Shows a signature help window while you type arguments for a function
    signature = { enabled = true },
  }
end end

-- ============================================================
-- SECTION 8: TREESITTER
-- Parser installation, syntax highlighting, folds, indentation — terminal only
-- ============================================================
if not is_vscode then do
  -- [[ Configure Treesitter ]]
  --  Used to highlight, edit, and navigate code
  --
  --  See `:help nvim-treesitter-intro`

  vim.pack.add { { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main' } }

  -- Ensure basic parsers are installed
  local parsers = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' }
  require('nvim-treesitter').install(parsers)

  ---@param buf integer
  ---@param language string
  local function treesitter_try_attach(buf, language)
    if not vim.treesitter.language.add(language) then return end
    vim.treesitter.start(buf, language)

    -- Enable treesitter based folds
    -- For more info on folds see `:help folds`
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
-- Port từ vscodevim settings (vim.normalModeKeyBindingsNonRecursive, v.v.)
-- sang vscode-neovim + kickstart. Dùng require('vscode').action() để
-- gọi VSCode commands thay vì Telescope / LSP / neovim built-ins.
-- ============================================================
if is_vscode then
  local vscode = require 'vscode'
  local function act(cmd) return function() vscode.action(cmd) end end

  -- ── File & Search ────────────────────────────────────────────
  vim.keymap.set('n', '<C-p>', act 'workbench.action.quickOpen', { desc = 'Quick Open file' })
  vim.keymap.set('n', '<C-f>', act 'actions.find', { desc = 'Find in current file' })
  vim.keymap.set('n', '<leader>sf', act 'workbench.action.quickOpen', { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sg', act 'workbench.action.findInFiles', { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader><leader>', act 'workbench.action.showAllEditors', { desc = 'Find existing editors' })
  vim.keymap.set('n', '<leader>/', act 'fuzzySearch.activeTextEditor', { desc = '[/] Fuzzy search in file' })
  vim.keymap.set('v', '<leader>/', act 'fuzzySearch.activeTextEditorWithCurrentSelection', { desc = '[/] Fuzzy search selection' })

  -- Find It Faster (cần extension: find-it-faster)
  vim.keymap.set('n', '<leader>ff', act 'find-it-faster.findFiles', { desc = '[F]ind [F]iles (fzf)' })
  vim.keymap.set('n', '<leader>fF', act 'find-it-faster.findFilesWithType', { desc = '[F]ind Files with [F]iletype' })
  vim.keymap.set('n', '<leader>fs', act 'find-it-faster.findWithinFiles', { desc = '[F]ind within file[s]' })
  vim.keymap.set('n', '<leader>fS', act 'find-it-faster.findWithinFilesWithType', { desc = '[F]ind within files + [S]elect type' })

  -- ── LSP / Code Actions ───────────────────────────────────────
  -- g-prefixed: mirrors user's vscodevim gd, gr, gi, gt... bindings
  vim.keymap.set('n', 'gd', act 'editor.action.revealDefinition', { desc = '[G]oto [D]efinition' })
  vim.keymap.set('n', 'gp', act 'editor.action.peekDefinition', { desc = '[G]oto [P]eek definition' })
  vim.keymap.set('n', 'gD', act 'editor.action.revealDeclaration', { desc = '[G]oto [D]eclaration' })
  vim.keymap.set('n', 'gr', act 'editor.action.goToReferences', { desc = '[G]oto [R]eferences' })
  vim.keymap.set('n', 'gR', act 'references-view.find', { desc = '[G]oto [R]eferences (panel)' })
  vim.keymap.set('n', 'gi', act 'editor.action.goToImplementation', { desc = '[G]oto [I]mplementation' })
  vim.keymap.set('n', 'gt', act 'editor.action.peekTypeDefinition', { desc = '[G]oto [T]ype definition' })
  vim.keymap.set('n', 'gs', act 'workbench.action.gotoSymbol', { desc = '[G]oto document [S]ymbol' })
  vim.keymap.set('n', 'gS', act 'workbench.action.showAllSymbols', { desc = '[G]oto workspace [S]ymbol' })
  vim.keymap.set('n', 'gk', act 'editor.action.showHover', { desc = 'Show hover [K] (docs)' })
  vim.keymap.set('n', 'gf', act 'fuzzySearch.activeTextEditor', { desc = '[G]o [F]uzzy search' })

  -- gr-prefixed: kickstart-style aliases
  vim.keymap.set('n', 'grr', act 'editor.action.goToReferences', { desc = '[G]oto [R]eferences' })
  vim.keymap.set('n', 'grd', act 'editor.action.revealDefinition', { desc = '[G]oto [D]efinition' })
  vim.keymap.set('n', 'gri', act 'editor.action.goToImplementation', { desc = '[G]oto [I]mplementation' })
  vim.keymap.set('n', 'grt', act 'editor.action.goToTypeDefinition', { desc = '[G]oto [T]ype Definition' })
  vim.keymap.set('n', 'grn', act 'editor.action.rename', { desc = '[R]e[n]ame' })
  vim.keymap.set({ 'n', 'x' }, 'gra', act 'editor.action.quickFix', { desc = 'Code [A]ction' })
  vim.keymap.set('n', 'grD', act 'editor.action.revealDeclaration', { desc = '[G]oto [D]eclaration' })

  -- ── Format & Diagnostics ─────────────────────────────────────
  vim.keymap.set({ 'n', 'v' }, '<leader>f', act 'editor.action.formatDocument', { desc = '[F]ormat document' })
  vim.keymap.set('n', '<leader>q', act 'workbench.actions.view.problems', { desc = 'Open [Q]uickfix/Problems' })
  vim.keymap.set('n', '<leader>th', act 'editor.action.inlayHints.toggle', { desc = '[T]oggle Inlay [H]ints' })

  -- ── Rename / Refactor ────────────────────────────────────────
  vim.keymap.set('n', '<leader>r', act 'editor.action.rename', { desc = '[R]ename symbol' })
  vim.keymap.set('v', '<leader>;', act 'editor.action.refactor', { desc = 'Refactor' })

  -- ── Buffer / Editor ──────────────────────────────────────────
  vim.keymap.set('n', '<leader>bq', act 'workbench.action.closeActiveEditor', { desc = '[B]uffer [Q]uit' })
  vim.keymap.set('n', '<leader>bn', act 'workbench.action.files.newUntitledFile', { desc = '[B]uffer [N]ew' })
  vim.keymap.set('n', '<C-m>', act 'workbench.action.editor.changeLanguageMode', { desc = 'Change language mode' })

  -- ── Sidebar & UI ─────────────────────────────────────────────
  vim.keymap.set('n', '<leader>e', act 'workbench.action.toggleSidebarVisibility', { desc = 'Toggle [E]xplorer sidebar' })
  vim.keymap.set('n', '<leader>>', act 'workbench.action.showCommands', { desc = 'Command [>] palette' })

  -- ── Pane / Window focus ──────────────────────────────────────
  -- NOTE: <C-j>/<C-k> ở đây là move lines (đã set ở Section 1 visual mode)
  -- Để focus pane dùng <leader>w prefix
  vim.keymap.set('n', '<leader>wh', act 'workbench.action.focusLeftGroup', { desc = '[W]indow focus left' })
  vim.keymap.set('n', '<leader>wl', act 'workbench.action.focusRightGroup', { desc = '[W]indow focus right' })
  vim.keymap.set('n', '<leader>wk', act 'workbench.action.focusAboveGroup', { desc = '[W]indow focus above' })
  vim.keymap.set('n', '<leader>wj', act 'workbench.action.focusBelowGroup', { desc = '[W]indow focus below' })
  -- C-h/C-l vẫn dùng cho focus (không có conflict với line move)
  vim.keymap.set('n', '<C-h>', act 'workbench.action.focusLeftGroup', { desc = 'Focus left editor group' })
  vim.keymap.set('n', '<C-l>', act 'workbench.action.focusRightGroup', { desc = 'Focus right editor group' })
  -- C-j/C-k: move lines trong normal mode ở VSCode (khác terminal dùng C-j/k cho window)
  vim.keymap.set('n', '<C-j>', act 'editor.action.moveLinesDownAction', { desc = 'Move line down' })
  vim.keymap.set('n', '<C-k>', act 'editor.action.moveLinesUpAction', { desc = 'Move line up' })

  -- ── Terminal ─────────────────────────────────────────────────
  vim.keymap.set('n', '<leader>tf', act 'workbench.action.terminal.focus', { desc = '[T]erminal [F]ocus' })
  vim.keymap.set('n', '<leader>tn', act 'workbench.action.terminal.new', { desc = '[T]erminal [N]ew' })
  vim.keymap.set('n', '<leader>tk', act 'workbench.action.terminal.killTerminalAfterUse', { desc = '[T]erminal [K]ill' })

  -- ── Git ──────────────────────────────────────────────────────
  vim.keymap.set('n', '<leader>gd', act 'git.viewChanges', { desc = '[G]it [D]iff changes' })
  vim.keymap.set('n', '<leader>ga', act 'git.stageAll', { desc = '[G]it [A]dd all (stage)' })
  vim.keymap.set('n', '<leader>gc', act 'git.commit', { desc = '[G]it [C]ommit' })
  vim.keymap.set('n', '<leader>gp', act 'git.pushTo', { desc = '[G]it [P]ush to...' })
  vim.keymap.set('n', '<leader>gP', act 'git.pullFrom', { desc = '[G]it [P]ull from...' })
  vim.keymap.set('n', '<leader>gk', act 'git.checkout', { desc = '[G]it chec[K]out branch' })
  vim.keymap.set('n', '<leader>gu', act 'git.unstage', { desc = '[G]it [U]nstage' })
  vim.keymap.set('n', '<leader>guc', act 'git.undoCommit', { desc = '[G]it [U]ndo [C]ommit' })
  vim.keymap.set('n', '<leader>goc', act 'git.viewChanges', { desc = '[G]it [O]pen [C]hanges' })
  vim.keymap.set('n', '<leader>gos', act 'git.viewStagedChanges', { desc = '[G]it [O]pen [S]taged' })
  vim.keymap.set('n', '<leader>gcp', act 'git.cherryPick', { desc = '[G]it [C]herry [P]ick' })
  vim.keymap.set('n', '<leader>gdb', act 'git.deleteBranch', { desc = '[G]it [D]elete [B]ranch' })

  -- ── Bookmarks (cần extension: alefragnani.Bookmarks) ─────────
  vim.keymap.set('n', '<leader>mt', act 'bookmarks.toggle', { desc = '[M]ark [T]oggle' })
  vim.keymap.set('n', '<leader>me', act 'bookmarks.toggleLabeled', { desc = '[M]ark [E]dit label' })
  vim.keymap.set('n', '<leader>mn', act 'bookmarks.jumpToNext', { desc = '[M]ark [N]ext' })
  vim.keymap.set('n', '<leader>mp', act 'bookmarks.jumpToPrevious', { desc = '[M]ark [P]rev' })
  vim.keymap.set('n', '<leader>ml', act 'bookmarks.list', { desc = '[M]ark [L]ist (file)' })
  vim.keymap.set('n', '<leader>mL', act 'bookmarks.listFromAllFiles', { desc = '[M]ark [L]ist (all files)' })
  vim.keymap.set('n', '<leader>mC', act 'bookmarks.clear', { desc = '[M]ark [C]lear' })

  -- ── Harpoon (cần extension: ThePrimeagen.harpoon) ────────────
  vim.keymap.set('n', '<leader>hp', act 'vscode-harpoon.editorQuickPick', { desc = '[H]arpoon [P]ick' })
  vim.keymap.set('n', '<leader>ha', act 'vscode-harpoon.addEditor', { desc = '[H]arpoon [A]dd' })
  vim.keymap.set('n', '<leader>he', act 'vscode-harpoon.editEditors', { desc = '[H]arpoon [E]dit list' })

  -- ── Project Manager (cần extension: alefragnani.project-manager) ──
  vim.keymap.set('n', '<leader>pl', act 'projectManager.listProjectsNewWindow', { desc = '[P]roject [L]ist (new window)' })
  vim.keymap.set('n', '<leader>pL', act 'projectManager.listProjects', { desc = '[P]roject [L]ist (current window)' })
  vim.keymap.set('n', '<leader>pe', act 'projectManager.editProjects', { desc = '[P]roject [E]dit' })
  vim.keymap.set('n', '<leader>pr', act 'projectManager.refreshProjects', { desc = '[P]roject [R]efresh' })

  -- ── Settings ─────────────────────────────────────────────────
  vim.keymap.set('n', '<leader>su', act 'workbench.action.openSettings', { desc = '[S]ettings [U]I' })
  vim.keymap.set('n', '<leader>sj', act 'workbench.action.openSettingsJson', { desc = '[S]ettings [J]SON' })
end

-- ============================================================
-- SECTION 10: OPTIONAL EXAMPLES / NEXT STEPS
-- kickstart.plugins.* examples
-- ============================================================
do
  -- The following comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
  -- require 'kickstart.plugins.debug'
  -- require 'kickstart.plugins.indent_line'
  -- require 'kickstart.plugins.lint'
  -- require 'kickstart.plugins.autopairs'
  -- require 'kickstart.plugins.neo-tree'
  -- require 'kickstart.plugins.gitsigns' -- adds gitsigns recommended keymaps

  -- NOTE: You can add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  -- require 'custom.plugins'
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
