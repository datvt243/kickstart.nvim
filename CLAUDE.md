# CLAUDE.md — Neovim Config (_david)

## Working rules

- **Only push code when explicitly asked.** Stop after committing — never push on your own.
- **Every time any keymap changes, update `keymaps-terminal.md` and/or `keymaps-vscode.md`.**
- **Every keymap (new or edited) must have an explanatory comment above it, and keymaps must be separated by a blank line** — no back-to-back `vim.keymap.set` calls without a blank line between them.
- **When introducing a new plugin** (proposing to install it, comparing it to another, or just answering "what is plugin X") **include GitHub star count and popularity/reputation** — fetch real numbers instead of guessing, since they change over time.
- **When installing a new plugin, verify it runs cleanly on both axes before considering it done:**
  1. **VSCode vs Terminal** — either it loads without error in both, or it's guarded to the right environment (`if vim.g.vscode ~= nil then return end` for terminal-only, `if vim.g.vscode == nil then return end` for VSCode-only). Never let a terminal-only plugin crash the VSCode session.
  2. **Windows vs macOS** — no OS-specific breakage: watch for path separators (`\` vs `/`), hardcoded Unix paths (`~/`, `/tmp`), external tools that only ship on one OS (e.g. `xmllint`, `make`), and spawning `.cmd`/`.bat` on Windows via `vim.system` (route through `cmd.exe /c`). Guard OS-specific code with `vim.fn.has 'win32'`. If a machine of the other OS isn't available, verify by static analysis + simulation and note that end-to-end testing on the other OS is still pending.

## Overview

This is a personal Neovim config based on kickstart.nvim, running in **two environments**:

- **Terminal Neovim** — full plugin stack
- **VSCode with vscode-neovim** (`asvetliakov.vscode-neovim`) — mini.ai + mini.surround + mini.move + flash.nvim + guess-indent; editor commands are called via `vscode.action()`

## File structure

```
init.lua                        — shared keymaps, vim.pack hooks, load plugins
lua/
  options.lua                    — vim.g/vim.o/vim.opt (leader keys, core options, swapfile, autosave); required by init.lua
  globals/init.lua               — global helper methods dùng chung (vd: `gh`); required by init.lua TRƯỚC khi load plugin
  custom/plugins/               — plugin files (auto-loaded recursively by init.lua)
    init.lua                    — auto-loader: requires every .lua file in the tree (incl. subfolders)
    dashboard.lua                — dashboard-nvim: welcome screen (terminal)
    lsp.lua                     — nvim-lspconfig + Mason + fidget + lazydev (terminal)
    telescope.lua                — Telescope fuzzy finder (terminal)
    vscode.lua                  — VSCode keymaps via vscode.action() (VSCode only)
    editor/                     — editing behavior / motion plugins, always auto-loaded (no opt-in toggle)
      flash.lua                 — flash.nvim: jump nhanh bằng s/S/<leader>j (both)
      text-objects.lua          — mini.surround + mini.move + guess-indent (both)
      neoscroll.lua              — neoscroll.nvim: smooth scrolling (terminal)
      smear-cursor.lua          — smear-cursor.nvim: animate con trỏ hiệu ứng smear/vệt kéo (terminal)
      scrollbar.lua              — nvim-scrollbar: git change/diagnostics on the scrollbar (terminal)
      indent_line.lua           — [ENABLED] indent guides (terminal)
      whichkey.lua              — which-key.nvim: keymap hints when pressing leader (terminal)
      trouble.lua               — trouble.nvim: diagnostics/quickfix/loclist/LSP refs list, <leader>x* (terminal)
      goto-preview.lua          — goto-preview.nvim: peek definition/type/impl/decl/refs editable,
                                    gp/gpt/gpi/gpD/gpr/gP/Esc (terminal)
      todo-comments.lua         — todo-comments.nvim: highlight TODO/FIXME/NOTE/HACK/WARN (terminal)
    coding/                     — language/code-writing helper plugins, always auto-loaded (no opt-in toggle)
      ts-comments.lua           — ts-comments.nvim: accurate comment string via treesitter (terminal)
      mini-ai.lua               — mini.ai: text objects mở rộng (both)
      autopairs.lua             — nvim-autopairs: auto-close brackets (terminal)
      blink-cmp.lua             — blink.cmp: autocomplete engine, marker `### BLINK.CMP KEYMAPS` (terminal)
      luasnip.lua               — LuaSnip: snippet engine, nguồn snippet cho blink.cmp (terminal)
      lazydev.lua               — lazydev.nvim: lua_ls type cho Neovim config/plugin (terminal)
    colorscheme/                — colorscheme + theme-adjacent UI plugins, always auto-loaded (no opt-in toggle)
      tokyonight.lua            — [INACTIVE] tokyonight.nvim: colorscheme, full setup options (terminal)
      catppuccin.lua            — [ACTIVE] catppuccin.nvim: colorscheme, full setup options (terminal)
    formatting/                 — code-formatting plugins, always auto-loaded (no opt-in toggle)
      conform.lua               — conform.nvim: formatter, <leader>qf/qF/qc (terminal)
    ui/                         — small standalone UI plugins, always auto-loaded (no opt-in toggle)
      icons.lua                 — mini.icons: icon theo filetype, mock_nvim_web_devicons() — LOAD TRƯỚC (xem custom/plugins/init.lua)
      lualine.lua               — lualine.nvim: statusline, theme = 'auto' theo colorscheme active (terminal)
      noice.lua                 — noice.nvim: floating cmdline + notifications (terminal)
      bufferline.lua            — [DISABLED via `local enabled = false` in file] tab bar showing open buffers, themable;
                                    tabline global (không tách theo split) → xem winbar.lua để hiện tên file theo từng split (terminal)
      winbar.lua                — winbar built-in: hiện tên file ở đầu MỖI split, ẩn ở neo-tree/terminal/qf/help (terminal)
      render-markdown.lua       — render-markdown.nvim: render markdown ngay trong buffer khi edit .md (terminal)
      colorizer.lua             — nvim-colorizer.lua (catgoose): tô màu theo giá trị màu hex/rgb/hsl/tên/Tailwind (terminal)
    treesitter/                 — syntax parsing, always auto-loaded (no opt-in toggle)
      treesitter.lua            — nvim-treesitter (terminal)
      autotag.lua               — nvim-ts-autotag: auto-close/rename cặp thẻ HTML/JSX/TSX (terminal)
    tools/                      — external tool integrations, always auto-loaded (no opt-in toggle)
      claudecode.lua            — Claude Code integration (terminal)
      project.lua               — project.nvim: auto-detect root + Telescope picker; tự đóng buffer
                                    chưa sửa khi đổi project (DirChanged) (terminal)
      terminal.lua              — toggleterm.nvim: small terminal at the bottom (terminal)
      codesnap.lua              — codesnap.nvim: capture code as an image (terminal)
      import-cost.lua           — vim-import-cost: shows KB per JS/TS import (terminal)
  kickstart/plugins/            — optional plugins (uncomment in Section 10 to enable)
    debug.lua                   — DAP debugger
    gitsigns.lua                — [ENABLED] full git keymaps
    lint.lua                    — linter
    neo-tree.lua                — [ENABLED] advanced file explorer: \, <leader>e, <leader>ee
  health.lua                    — config health check
```

> `custom/plugins/ui/icons.lua` is `require`d explicitly at the top of `custom/plugins/init.lua`, before the recursive loader runs — it calls `mini.icons`'s `mock_nvim_web_devicons()`, and every other plugin that calls `require('nvim-web-devicons')` (Telescope, Neo-tree, lualine, bufferline) needs that mock in place first. Directory-walk order isn't guaranteed, so don't remove this early require.
>
> Subfolders under `custom/plugins/` (`editor/`, `coding/`, `colorscheme/`, `formatting/`, `ui/`, `treesitter/`, ...) are loaded by the same recursive auto-loader — files there **cannot** be disabled by commenting a require in Section 10. To disable one, add a local `enabled`/`active` flag inside the file itself (see `bufferline.lua` for the pattern).
>
> **Switching colorscheme:** both `colorscheme/tokyonight.lua` and `colorscheme/catppuccin.lua` always run `vim.pack.add` + `.setup()` (so the plugin is always installed and configured). Which one actually gets applied is decided in `init.lua`, right after `require 'custom.plugins'`, via `local active_colorscheme = '...'` + `vim.cmd.colorscheme(active_colorscheme)`. To switch, change that string (e.g. `'catppuccin'` or `'tokyonight-night'`), then `:ReloadConfig` or restart.

## init.lua — Section layout

| Section | Content | Environment |
|---|---|---|
| 1 | `require 'options'` + shared keymaps | Both |
| 2 | vim.pack build hooks (PackChanged) | Terminal only |
| — | `require 'custom.plugins'` — loads all plugin files | — |
| 10 | Optional plugins (kickstart/plugins/) | Terminal only |

> Sections 3–9 have been split out into separate files under `lua/custom/plugins/`.

## Important patterns

### Environment detection
```lua
local is_vscode = vim.g.vscode ~= nil   -- used in files that behave differently per environment (e.g. editor/text-objects.lua)
```

### Guard for terminal-only files (early return)
```lua
if vim.g.vscode ~= nil then return end  -- place at the top of the file, before any other code
```

### Guard for VSCode-only files
```lua
if vim.g.vscode == nil then return end  -- e.g.: vscode.lua
```

### Calling a VSCode command
```lua
local vscode = require 'vscode'
local function act(cmd) return function() vscode.action(cmd) end end
-- Or use the shorthand helper in vscode.lua:
local function n(key, cmd, desc) vim.keymap.set('n', key, act(cmd), { desc = desc }) end
n('gd', 'editor.action.revealDefinition', 'Goto definition')
```

### Plugin manager
```lua
-- vim.pack is the built-in plugin manager (not lazy.nvim)
-- `gh 'user/repo'` → full GitHub URL. `gh` is a GLOBAL defined in lua/globals/init.lua
-- (loaded before plugins in init.lua), so plugin files call it directly — DON'T redeclare
-- `local function gh` per file. New shared globals: add to lua/globals/init.lua AND to
-- Lua.diagnostics.globals in lua/custom/plugins/lsp.lua.
vim.pack.add { gh 'user/repo' }

-- Update:           :PackUpdate
-- Check status:      :lua vim.pack.update(nil, { offline = true })
-- Reload config:     :ReloadConfig (no need to quit/reopen Neovim)
```

### Plugin setup config (convention)
Every plugin file exposes its `setup()` options as a single `local config = {...}` block near the top (right after `vim.pack.add`), marked with a banner comment, then calls `setup(config)`. Keep this pattern when adding/editing a plugin so all tunable values live in one place at the top of each file.
```lua
vim.pack.add { gh 'user/repo' }

-- ═══ CONFIG — chỉnh giá trị plugin ở đây; setup(config) bên dưới dùng lại ═══
local config = {
  some_option = true,
}

require('plugin').setup(config)
```
- **Multiple `setup()` calls in one file** → give each its own descriptive variable (e.g. `move_config` in `editor/text-objects.lua`), not a shared `config`.
- **Empty `setup {}` / `setup()`** (no options) → leave as-is; wrapping an empty table adds noise with nothing to tune.
- **`setup()` guarded by an `if`** (e.g. `tools/claudecode.lua`) → declare `local config` inside that block, just before the call, to keep the guard intact.

## Quick search (type `/###`)

`###` markers are scattered across plugin files:

| Marker | File | Content |
|---|---|---|
| `### KEYMAPS CHUNG` | `init.lua` | j/k, {/}, buffer, save, indent, move lines, splits |
| `### MINI.AI` | `custom/plugins/coding/mini-ai.lua` | text objects: af/if (function), ac/ic (class), treesitter |
| `### MINI.SURROUND` | `custom/plugins/editor/text-objects.lua` | add/delete/replace surround |

## VSCode — Required extensions

| Extension | ID | Purpose |
|---|---|---|
| vscode-neovim | `asvetliakov.vscode-neovim` | Real Neovim embedded in VSCode |
| Which Key | `vspacecode.whichkey` | `\` → keymap hint menu |
| Find It Faster | `TomiTurtinen.find-it-faster` | leader ff/fF/fs/fS |
| Fuzzy Search | `jacobdufault.fuzzy-search` | leader / |
| Bookmarks | `alefragnani.Bookmarks` | leader m* |
| Harpoon | `tobias-z.vscode-harpoon` | leader h* |
| Project Manager | `alefragnani.project-manager` | leader p* |

> **Jump:** Use `flash.nvim` (a Neovim plugin) instead of Jumpy — `<leader>j`. Jumpy conflicts with vscode-neovim due to its `type` command hook.

> **Note:** `vscodevim.vim` must be disabled if installed — the two extensions conflict.
> Run: `code --disable-extension vscodevim.vim`

> **Which Key:** the `\` trigger is set in `keybindings.json` (not Lua) so that
> vspacecode.whichkey works correctly with vscode-neovim.

## Adding a new LSP server

Open `lua/custom/plugins/lsp.lua`, find `local servers = {`, and add to it:
```lua
local servers = {
  ts_ls = {},
  pyright = {},   -- new
  -- ...
}
```
Mason will install it automatically on the next Neovim restart.

## Adding a new formatter

Open `lua/custom/plugins/formatting/conform.lua`, find `formatters_by_ft`:
```lua
formatters_by_ft = {
  python = { 'black' },  -- new
  -- ...
}
```

## Enabling an optional plugin

- **`kickstart/plugins/*.lua`** (opt-in): uncomment its `require` in Section 10 of `init.lua`.
  ```lua
  require 'kickstart.plugins.lint'
  ```
  Then restart Neovim.
- **subfolders under `custom/plugins/`** (`editor/`, `coding/`, `colorscheme/`, `formatting/`, `ui/`, `treesitter/`) — always auto-loaded, no Section 10 toggle: if the file has a local `enabled`/`active` flag (e.g. `ui/bufferline.lua`, `colorscheme/*.lua`), flip it. Otherwise the plugin is already active by virtue of being in the directory.

## Formatting Lua code

```bash
~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua
```

## Kiểm tra config (health check)

```bash
./scripts/health.sh
```
Chạy headless (không cần mở Neovim), 3 bước: [1] load config bắt lỗi startup → [2] `luac -p` parse toàn bộ `.lua` → [3] `:checkhealth` đếm ERROR/WARNING. Exit code 0 nếu sạch, khác 0 nếu có ERROR/parse fail → dùng được trong pre-commit / CI. Nên chạy sau khi sửa config hoặc thêm/sửa plugin.
