# CLAUDE.md — Neovim Config (_david)

## Working rules

- **Only push code when explicitly asked.** Stop after committing — never push on your own.
- **Every time any keymap changes, update `keymaps-terminal.md` and/or `keymaps-vscode.md`.**

## Overview

This is a personal Neovim config based on kickstart.nvim, running in **two environments**:

- **Terminal Neovim** — full plugin stack
- **VSCode with vscode-neovim** (`asvetliakov.vscode-neovim`) — mini.ai + mini.surround + mini.move + flash.nvim + guess-indent; editor commands are called via `vscode.action()`

## File structure

```
init.lua                        — options, shared keymaps, vim.pack hooks, load plugins
lua/
  custom/plugins/               — plugin files (auto-loaded by init.lua)
    init.lua                    — auto-loader: requires every .lua file in the directory
    completion.lua              — blink.cmp + LuaSnip (terminal)
    dashboard.lua               — dashboard-nvim: welcome screen (terminal)
    format.lua                  — conform.nvim: formatter (terminal)
    lsp.lua                     — nvim-lspconfig + Mason + fidget + lazydev (terminal)
    telescope.lua               — Telescope fuzzy finder (terminal)
    treesitter.lua              — nvim-treesitter (terminal)
    claudecode.lua              — Claude Code integration (terminal)
    noice.lua                   — noice.nvim: floating cmdline + notifications (terminal)
    project.lua                 — project.nvim: auto-detect root + Telescope picker (terminal)
    terminal.lua                — toggleterm.nvim: small terminal at the bottom (terminal)
    codesnap.lua                — codesnap.nvim: capture code as an image (terminal)
    import-cost.lua             — vim-import-cost: shows KB per JS/TS import (terminal)
    scrollbar.lua               — nvim-scrollbar: git change/diagnostics on the scrollbar (terminal)
    neoscroll.lua               — neoscroll.nvim: smooth scrolling (terminal)
    ts-comments.lua             — ts-comments.nvim: accurate comment string via treesitter (terminal)
    ui.lua                      — mini.nvim (ai, surround, move), flash.nvim, tokyonight... (both)
    whichkey.lua                — which-key.nvim: keymap hints when pressing leader (terminal)
    vscode.lua                  — VSCode keymaps via vscode.action() (VSCode only)
  kickstart/plugins/            — optional plugins (uncomment in Section 10 to enable)
    autopairs.lua               — [ENABLED] auto-close brackets
    bufferline.lua              — bufferline.nvim: tab bar showing open buffers
    debug.lua                   — DAP debugger
    gitsigns.lua                — [ENABLED] full git keymaps
    indent_line.lua             — indent guides
    lint.lua                    — linter
    neo-tree.lua                — [ENABLED] advanced file explorer: \, <leader>e, <leader>ee
  health.lua                    — config health check
```

## init.lua — Section layout

| Section | Content | Environment |
|---|---|---|
| 1 | Options + shared keymaps | Both |
| 2 | vim.pack build hooks (PackChanged) | Terminal only |
| — | `require 'custom.plugins'` — loads all plugin files | — |
| 10 | Optional plugins (kickstart/plugins/) | Terminal only |

> Sections 3–9 have been split out into separate files under `lua/custom/plugins/`.

## Important patterns

### Environment detection
```lua
local is_vscode = vim.g.vscode ~= nil   -- used in ui.lua (serves both environments)
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
local function gh(repo) return 'https://github.com/' .. repo end
vim.pack.add { gh 'user/repo' }

-- Update:           :PackUpdate
-- Check status:      :lua vim.pack.update(nil, { offline = true })
-- Reload config:     :ReloadConfig (no need to quit/reopen Neovim)
```

## Quick search (type `/###`)

`###` markers are scattered across plugin files:

| Marker | File | Content |
|---|---|---|
| `### KEYMAPS CHUNG` | `init.lua` | j/k, {/}, buffer, save, indent, move lines, splits |
| `### MINI.AI` | `ui.lua` | text objects: af/if (function), ac/ic (class), treesitter |
| `### MINI.SURROUND` | `ui.lua` | add/delete/replace surround |

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

Open `lua/custom/plugins/format.lua`, find `formatters_by_ft`:
```lua
formatters_by_ft = {
  python = { 'black' },  -- new
  -- ...
}
```

## Enabling an optional plugin

Uncomment it in Section 10 of `init.lua`:
```lua
require 'kickstart.plugins.indent_line'
```
Then restart Neovim.

## Formatting Lua code

```bash
~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua
```
