# doctrine/domains/PROJECT.md — ground truth for nvim-config

## What is it
Personal Neovim config for `_david`, based on kickstart.nvim, forked at
`github.com/datvt243/kickstart.nvim`. Runs in two environments:
**Terminal Neovim** (full plugin stack — LSP, Telescope, Treesitter,
blink.cmp, flash.nvim...) and **VSCode + vscode-neovim** (a smaller
subset: mini.ai, mini.surround, mini.move, flash.nvim, guess-indent;
commands dispatched via `vscode.action()`).

## Stack + shape
| Thing | Value |
|---|---|
| Language/runtime | Lua, Neovim 0.11+ |
| Entry point | `init.lua` (shared keymaps, `vim.pack` hooks, loads `lua/custom/plugins/`) |
| Data store | N/A — no data store; `nvim-pack-lock.json` pins plugin versions |

Key directories: `lua/options.lua` (vim.g/vim.o/vim.opt), `lua/globals/init.lua`
(shared global helpers, e.g. `gh`), `lua/custom/plugins/` (auto-loaded
recursively by `init.lua`, subfolders `editor/`, `coding/`, `colorscheme/`,
`formatting/`, `ui/`, `treesitter/`, `tools/` — always auto-loaded, no
Section-10 opt-in toggle), `lua/kickstart/plugins/` (optional, enabled by
uncommenting in `init.lua` Section 10).

## Invariants (things that never happen here)
- Only push when explicitly asked — stop after committing (see
  `agent-hub/CLAUDE.md`'s Seal gate; this project's rule is stricter than
  the hub default: not even after SEAL does a push happen unasked).
- Every keymap change updates `keymaps-terminal.md` and/or
  `keymaps-vscode.md` — never left to drift.
- Every keymap (new or edited) carries an explanatory comment, and
  consecutive `vim.keymap.set` calls are separated by a blank line.
- Proposing/installing a new plugin always cites real GitHub star count +
  popularity — fetched, never guessed.
- A new/changed plugin is verified on 2 axes before considered done:
  **VSCode vs Terminal** (loads clean in both, or guarded —
  `if vim.g.vscode ~= nil then return end` for terminal-only,
  `if vim.g.vscode == nil then return end` for VSCode-only) and
  **Windows vs macOS** (path separators, hardcoded Unix paths, OS-only
  external tools, `.cmd`/`.bat` spawning via `vim.system` routed through
  `cmd.exe /c`, guarded with `vim.fn.has 'win32'`).
- New shared global helpers go in `lua/globals/init.lua` AND get added to
  `Lua.diagnostics.globals` in `lua/custom/plugins/lsp.lua` — plugin files
  call the global directly, never redeclare a local copy per file.

## Diagram-first
The diagram (`haven/diagrams/`) is the source of truth for progress —
code must match it.

## Forbidden states
See `CLAUDE.md` — `ADHOC_WORK`, `NO_EVIDENCE`, `EDIT_UNVERIFIED`,
`CODE_IN_HAVEN`, `DIAGRAM_DRIFT`.

> TOKEN DISCIPLINE: this file is read IN FULL every worker session
> (implementer, verifier, each separate subagent). When the file exceeds
> ~15KB: move Traps/Decisions rows that are no longer recent work to
> `PROJECT-archive.md` (same directory) — copy each row VERBATIM (DO NOT
> DELETE, DO NOT shorten), then keep only the rows still relevant to
> current work here. Same convention as the diagram's
> `dev-loop-archive.md`. Checked by `/hub-tokens`.

## Traps (append when you hit a new one)
| Trap | Why | What to do instead |
|---|---|---|
| `ui/icons.lua` not loaded before other UI plugins | `mini.icons`' `mock_nvim_web_devicons()` must be in place before Telescope/Neo-tree/lualine/bufferline call `require('nvim-web-devicons')`; the recursive directory-walk load order under `custom/plugins/` isn't guaranteed | Keep the explicit `require 'custom.plugins.ui.icons'` at the top of `custom/plugins/init.lua`, before the recursive loader runs |
| Jumpy-style jump plugins conflict with vscode-neovim | Such plugins hook the `type` command, which conflicts with how vscode-neovim intercepts input | Use `flash.nvim`'s `<leader>j` instead — works in both Terminal and VSCode |
| `vscodevim.vim` installed alongside `vscode-neovim` | The two extensions both try to own Vim emulation in VSCode, conflicting | Disable it: `code --disable-extension vscodevim.vim` |

## Decisions, with reasoning
> A decision recorded without its reason will get "tidied up" away by a
> future agent — the *what* already exists in the code, only the *why*
> is load-bearing.

| Date | Decision | Why | Alternative rejected |
|---|---|---|---|
| `<<FILL>>` | Use `vim.pack` (Neovim's built-in plugin manager) instead of a third-party manager | Built into Neovim 0.11+, no external plugin-manager dependency to bootstrap/maintain | `lazy.nvim` |
| `<<FILL>>` | Keep `tokyonight.lua` always installed + configured but inactive; `catppuccin.lua` active | Both colorscheme files always run `vim.pack.add`+`.setup()`; which one actually applies is a single `local active_colorscheme` string in `init.lua`, so switching is a 1-line change, no reinstall | Removing the inactive colorscheme file entirely |
