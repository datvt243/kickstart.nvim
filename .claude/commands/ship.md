Perform the following steps in order to sync docs, then commit and push code.

## Step 1 — Update keymaps.md

Read all keymaps from source files in this order:
- `init.lua` (marker `### KEYMAPS CHUNG`)
- `lua/custom/plugins/ui.lua` (markers: `### MINI.AI`, `### MINI.SURROUND`, `### MINI.MOVE`, `### FLASH.NVIM`)
- `lua/custom/plugins/telescope.lua` (marker `### TELESCOPE KEYMAPS`)
- `lua/custom/plugins/lsp.lua` (marker `### LSP KEYMAPS`)
- `lua/custom/plugins/completion.lua` (marker `### BLINK.CMP KEYMAPS`)
- `lua/custom/plugins/format.lua` (marker `### FORMAT KEYMAP`)
- `lua/custom/plugins/vscode.lua` (all `###` markers in this file)

Compare with the current `keymaps.md` and update any keys, descriptions, or sections that are missing or have changed. Preserve the existing table format and legend. Only add/edit/remove what is actually different.

## Step 2 — Commit and push

After keymaps.md has been updated:

1. Run `git status` and `git diff` to see all changes (including staged and unstaged).
2. Read `git log --oneline -5` to understand the commit message style.
3. Stage all changed files by specific name — do not use `git add .`.
4. Write a concise commit message that accurately reflects the changes.
5. **Push to remote immediately after committing** — this is the ship command, push is required.
