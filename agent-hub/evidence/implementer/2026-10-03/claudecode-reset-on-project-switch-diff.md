# 2026-10-03 — claudecode-reset-on-project-switch — diff

- Worker: implementer
- Node: `claudecode-reset-on-project-switch`
- Issue: #3
- Branch: `3-claude-code-giu`
- Plan note: `evidence/implementer/2026-10-03/claudecode-reset-on-project-switch-plan.md`

## Diff
`lua/custom/plugins/tools/claudecode.lua` — added one `DirChanged`
autocmd (18 lines), appended after the existing keymaps. This diff was
already present as an uncommitted change on `master` before this
`/todo` run; the operator chose to use it as the starting point. This
pass reviewed it against the real `claudecode.nvim` source, ran the
real test command, and ran functional checks — no code change was
needed beyond what was already written (`SmallestDiff`: zero extra
lines added).

```diff
+-- claudecode.nvim cache terminal buffer/job: toggle lại chỉ focus buffer cũ, KHÔNG spawn
+-- job mới theo cwd hiện tại (xem native.lua open_terminal() -> is_valid()) — nên đổi project
+-- (project.nvim <leader>sp hoặc tự detect root) vẫn giữ session CLI cũ, process cũ đứng yên ở
+-- cwd cũ. Kill terminal cũ ngay khi DirChanged để lần mở tiếp theo (<leader>cc) spawn job mới
+-- đúng cwd project hiện tại, tránh lẫn ngữ cảnh giữa 2 project (issue #3).
+vim.api.nvim_create_autocmd('DirChanged', {
+  group = vim.api.nvim_create_augroup('claudecode-close-on-project-switch', { clear = true }),
+  callback = function(event)
+    if event.match ~= 'global' then return end
+    if not (package.loaded.claudecode and package.loaded.claudecode.state and package.loaded.claudecode.state.initialized) then return end
+    local bufnr = require('claudecode.terminal').get_active_terminal_bufnr()
+    if bufnr then vim.api.nvim_buf_delete(bufnr, { force = true }) end
+  end,
+})
```

## Command (`doctrine/MEMORY.md`, copied verbatim)
`./scripts/health.sh`, run from repo root (`/Users/_david/.config/nvim`).

## Output (read back verbatim)
```
[1/3] load config...
  ✓ OK
[2/3] parse .lua...
  ✓ OK (49 files)
[3/3] checkhealth...
  → 0 ERROR, 44 WARNING

DONE ✓ — không có lỗi
```
Matches the prior sealed baseline (44 WARNING, 0 ERROR,
`evidence/verifier/2026-09-28/dashboard-exclude-indent-guides-seal.md`)
exactly — no new warning/error introduced by this diff.

## Functional checks (headless simulation, not just code reading)

**Positive case** — real `:terminal sleep 60` buffer, stubbed
`package.loaded.claudecode.state.initialized = true` and
`claudecode.terminal.get_active_terminal_bufnr()` to return that real
buffer, then fired a global `:cd /tmp` (same scope `project.nvim` uses
— `project.lua`'s own comment: "project.nvim đổi cwd bằng lệnh `cd`
(scope mặc định 'global')") and ran the exact autocmd body from the
diff:
```
pid=1313
buf_valid_before=true
buf_valid_after=false
```
Process liveness check on the real PID after the delete:
```
STILL ALIVE (BUG)   <- did not happen
DEAD (job killed, correct)   <- actual result
```
Confirms the buffer delete genuinely terminates the underlying job, not
just hides it (see the `claudecode.nvim` `M.close()` trap recorded in
`doctrine/domains/PROJECT.md` — `M.close()` alone would have leaked the
process).

**Negative case** — same setup, but (a) plugin not yet initialized
(`package.loaded.claudecode = nil`, stub `get_active_terminal_bufnr`
raises an error if ever called) and a window-local `:lcd /tmp` fired
first:
```
lcd_ok=true
buf_valid_after_lcd=true
```
No error, no deletion — the `event.match ~= 'global'` guard and the
`initialized` guard both held. Then (b), after marking initialized and
firing a real global `:cd /var`:
```
buf_valid_after_global_cd=false
```
Confirms the positive path still fires correctly right after the
negative path, same autocmd instance — no state leak between calls.

Full scripts (for reproducibility): `/tmp/test_claudecode_dirchanged.lua`,
`/tmp/test_claudecode_dirchanged_neg.lua`.

## 2-axis check (`doctrine/domains/PROJECT.md`)
- **VSCode vs Terminal**: whole file guarded by
  `if vim.g.vscode ~= nil then return end` (line 4, pre-existing,
  unchanged) — new autocmd is terminal-only by inheritance of that
  guard, never registered under vscode-neovim.
- **Windows vs macOS**: diff is pure Neovim Lua API
  (`nvim_create_autocmd`, `nvim_create_augroup`, `nvim_buf_delete`,
  `require`) — no path separators, no `~`/`/tmp` literals, no OS-only
  external tool, no `.cmd`/`.bat` spawn. Static-analysis clean on both;
  no Windows machine available this session, so real end-to-end
  Windows verification is still pending.

## Formatting
`~/.local/share/nvim/mason/bin/stylua --check
lua/custom/plugins/tools/claudecode.lua` → exit 0, no diff needed.

## Keymap doc sync
N/A — no `vim.keymap.set` added or changed in this diff. No
`keymaps-terminal.md`/`keymaps-vscode.md` update required.

## Trap recorded
`doctrine/domains/PROJECT.md` Traps table — `claudecode.nvim`'s
`terminal.close()` doesn't kill the job (leaks the hidden buffer+job);
force-deleting the real bufnr does. See that file for the full entry.

## Seal gate
None — no commit/push/publish happened in this pass (local file edits
+ a headless functional test only, repo file itself already matched
what's needed). Push still requires separate explicit approval per
this repo's stricter push rule (`CLAUDE.md`, `doctrine/domains/
PROJECT.md` invariants).

## Status
`sealed_pending_verifier`.

## Hub bytes before
43177 (recorded in the plan note, same measurement this pass started
from).
