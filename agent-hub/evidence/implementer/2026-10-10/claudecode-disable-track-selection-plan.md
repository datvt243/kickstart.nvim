# 2026-10-10 — claudecode-disable-track-selection — PLAN

- Worker: implementer
- Version: 0.1.0
- Node: `claudecode-disable-track-selection` (`haven/diagrams/dev-loop.prime-mermaid.md`, new node, state IN_PROGRESS)
- Issue: #4 https://github.com/datvt243/kickstart.nvim/issues/4 — branch `4-neo-tree-chon-file`
- Task (verbatim): "Issue #4: Neo-tree: chọn file khi đang mở Claude Code thì file hiện vào input của Claude — Khi đang ở nvim Claude Code (claudecode.nvim), rồi chọn 1 file ở neo-tree thì thấy Claude Code hiện file đó ở input — hãy kiểm tra (đây là hành vi mong muốn/tính năng hay lỗi do config, và xử lý nếu cần)."

## Hub bytes before: 46158

## No PENDING node matched
All existing nodes are SEALED. New work from issue #4 → new node per LAI-13.

## Investigation (root cause)
- Not a config bug: claudecode.nvim's `track_selection` defaults to `true`
  (`~/.local/share/nvim/site/pack/core/opt/claudecode.nvim/lua/claudecode/config.lua:16`),
  and `lua/custom/plugins/tools/claudecode.lua` does not override it.
- `selection.lua` `_create_autocommands()` registers `CursorMoved`/`CursorMovedI`/`BufEnter`
  → `update_selection()` → `get_cursor_position()` (`selection.lua:760`) returns the
  current buffer's `filePath` → `server.broadcast("selection_changed", ...)` (`selection.lua:814`).
- Opening a file from Neo-tree fires `BufEnter` on that file → Claude CLI receives
  `selection_changed` and shows "⧉ In <file>" in its input area.

## Decision (operator)
Asked the user (AskUserQuestion) — options: keep + comment / disable / no change.
User chose **"Tắt track_selection"**. Manual sending stays available via
`<leader>cs` (visual `ClaudeCodeSend`; Neo-tree buffer `ClaudeCodeTreeAdd`).

## Acceptance criteria
1. `./scripts/health.sh` exits 0 (`Kết quả tổng: PASS`).
2. Headless Neovim with the real config: `require('claudecode').state.config.track_selection == false`
   and `require('claudecode.selection').state.tracking_enabled ~= true` (selection tracking
   autocmds never enabled → no `selection_changed` broadcast on BufEnter/CursorMoved).
3. No keymap changed (so `keymaps-terminal.md`/`keymaps-vscode.md` untouched).

## Code anchor
`lua/custom/plugins/tools/claudecode.lua` — `local config = { focus_after_send = true, terminal = {...} }`.

## No `<<FILL>>` blockers
`doctrine/MEMORY.md` test command filled (`./scripts/health.sh`).
