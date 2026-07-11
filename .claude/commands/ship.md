Perform the following steps in order to sync docs, then commit and push code.

## Step 1 — Update keymaps-terminal.md and keymaps-vscode.md

Read all keymaps from source files in this order:
- `init.lua` (marker `### KEYMAPS CHUNG`)
- `lua/custom/plugins/coding/mini-ai.lua` (marker `### MINI.AI`)
- `lua/custom/plugins/editor/text-objects.lua` (markers: `### MINI.SURROUND`, `### MINI.MOVE`)
- `lua/custom/plugins/editor/flash.lua` (marker `### FLASH.NVIM`, plus top-of-file `<leader>j` binding)
- `lua/custom/plugins/editor/trouble.lua` (marker `### TROUBLE.NVIM`)
- `lua/custom/plugins/editor/goto-preview.lua` (marker `### GOTO PREVIEW KEYMAPS`)
- `lua/custom/plugins/telescope.lua` (marker `### TELESCOPE KEYMAPS`)
- `lua/custom/plugins/lsp.lua` (marker `### LSP KEYMAPS`)
- `lua/custom/plugins/coding/blink-cmp.lua` (marker `### BLINK.CMP KEYMAPS`)
- `lua/custom/plugins/formatting/conform.lua` (marker `### FORMAT KEYMAP`)
- `lua/custom/plugins/tools/claudecode.lua` (marker `### CLAUDE CODE`)
- `lua/custom/plugins/tools/terminal.lua` (marker `### TERMINAL KEYMAPS`)
- `lua/custom/plugins/tools/project.lua` (marker `### PROJECT`)
- `lua/custom/plugins/vscode.lua` (all `###` markers in this file)
- `lua/kickstart/plugins/gitsigns.lua` (marker `### GIT COMMANDS`)
- `lua/kickstart/plugins/neo-tree.lua` (tất cả `vim.keymap.set` — không có marker)

Nếu không tìm thấy 1 file/marker nào ở trên (do cấu trúc thư mục đã đổi), chạy `grep -rn '### ' lua/custom/plugins/ lua/kickstart/plugins/` để tìm marker hiện tại trước khi bỏ qua nó.

Keymaps found only in terminal-only files (or guarded by `if vim.g.vscode ~= nil then return end`) go into `keymaps-terminal.md` with `Env = TER`. Keymaps found only in `vscode.lua` (or guarded by `if vim.g.vscode == nil then return end`) go into `keymaps-vscode.md` with `Env = VSC`. Keymaps that exist identically in both environments (e.g. shared `init.lua` bindings, or `<leader>j` in `flash.lua`) go into both files with `Env = BOTH`.

Compare with the current `keymaps-terminal.md` and `keymaps-vscode.md` and update any keys, descriptions, or sections that are missing or have changed. Preserve the existing table format and legend in each file. Only add/edit/remove what is actually different.

## Step 2 — Commit and push

After keymaps-terminal.md and keymaps-vscode.md have been updated:

1. Run `git status` and `git diff` to see all changes (including staged and unstaged).
2. Read `git log --oneline -5` to understand the commit message style.
3. Stage all changed files by specific name — do not use `git add .`.
4. Write a concise commit message that accurately reflects the changes.
5. **Push to remote immediately after committing** — this is the ship command, push is required.
