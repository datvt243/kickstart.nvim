Perform the following steps in order to sync docs, then commit and push code.

## Step 1 — Update keymaps-terminal.md and keymaps-vscode.md

Read all keymaps from source files in this order:
- `init.lua` (marker `### KEYMAPS CHUNG`)
- `lua/custom/plugins/ui.lua` (markers: `### MINI.AI`, `### MINI.SURROUND`, `### MINI.MOVE`, `### FLASH.NVIM`)
- `lua/custom/plugins/telescope.lua` (marker `### TELESCOPE KEYMAPS`)
- `lua/custom/plugins/lsp.lua` (marker `### LSP KEYMAPS`)
- `lua/custom/plugins/completion.lua` (marker `### BLINK.CMP KEYMAPS`)
- `lua/custom/plugins/format.lua` (marker `### FORMAT KEYMAP`)
- `lua/custom/plugins/claudecode.lua` (marker `### CLAUDE CODE`)
- `lua/custom/plugins/terminal.lua` (marker `### TERMINAL KEYMAPS`)
- `lua/custom/plugins/project.lua` (marker `### PROJECT`)
- `lua/custom/plugins/vscode.lua` (all `###` markers in this file)
- `lua/kickstart/plugins/gitsigns.lua` (marker `### GIT COMMANDS`)
- `lua/kickstart/plugins/neo-tree.lua` (tất cả `vim.keymap.set` — không có marker)

Keymaps found only in terminal-only files (or guarded by `if vim.g.vscode ~= nil then return end`) go into `keymaps-terminal.md` with `Env = TER`. Keymaps found only in `vscode.lua` (or guarded by `if vim.g.vscode == nil then return end`) go into `keymaps-vscode.md` with `Env = VSC`. Keymaps that exist identically in both environments (e.g. shared `init.lua`/`ui.lua` bindings) go into both files with `Env = BOTH`.

Compare with the current `keymaps-terminal.md` and `keymaps-vscode.md` and update any keys, descriptions, or sections that are missing or have changed. Preserve the existing table format and legend in each file. Only add/edit/remove what is actually different.

## Step 2 — Commit and push

After keymaps-terminal.md and keymaps-vscode.md have been updated:

1. Run `git status` and `git diff` to see all changes (including staged and unstaged).
2. Read `git log --oneline -5` to understand the commit message style.
3. Stage all changed files by specific name — do not use `git add .`.
4. Write a concise commit message that accurately reflects the changes.
5. **Push to remote immediately after committing** — this is the ship command, push is required.
