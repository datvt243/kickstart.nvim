# 2026-09-28 — dashboard-reopen-and-quiet

- Worker: implementer
- Version: 0.1.0
- Node: `dashboard-reopen-and-quiet` (`haven/diagrams/dev-loop.prime-mermaid.md`)
- Task (verbatim, issue #1): "Dashboard: (1) sau khi đóng hết buffer thì tự
  hiện lại dashboard-nvim thay vì màn hình trống; (2) tắt các lint/diagnostic
  hiển thị trên buffer dashboard (giống cách đã ẩn number/cursorline)"

## Hub bytes before: 45479
(root=8039, doctrine=13744, diagram active=2755, implementer bundle=10372,
verifier bundle=10569 — per `/hub-tokens` per-session formula)

## Diff
| File | Why |
|---|---|
| `lua/custom/plugins/dashboard.lua` | (a) `FileType dashboard` autocmd now also calls `vim.diagnostic.enable(false, { bufnr = ev.buf })` alongside the existing number/cursorline hides. (b) `BufDelete` autocmd's empty-scratch branch now marks the leftover auto-created scratch buffer `buflisted = false` and opens `Dashboard`, instead of force-deleting it (the force-delete raced with dashboard-nvim's own internal render callback in `hyper.lua` and caused an infinite error/reschedule crash loop — caught by the functional headless test below, fixed before this note was written). |

No keymap was added/changed — `keymaps-terminal.md`/`keymaps-vscode.md`
untouched, none needed.

## Command
`./scripts/health.sh`

## Output
```
[1/3] load config...
  ✓ OK
[2/3] parse .lua...
  ✓ OK (49 files)
[3/3] checkhealth...
  → 0 ERROR, 44 WARNING

DONE ✓ — không có lỗi
```
(44 WARNING matches the pre-existing baseline from the same command run
before this diff — no new warning introduced.)

## Functional check (headless, beyond health.sh)
`health.sh` only proves load/parse/checkhealth are clean — it doesn't
exercise the actual autocmd behavior, so a second headless script was run:
`nvim --headless "+luafile <scratch>/dashboard-check.lua"` — opens a real
temp file, runs `:bdelete`, reads back `&filetype` and
`vim.diagnostic.is_enabled({bufnr=0})`.

- First run (force-delete version): **hung** — `hyper.lua:549: Invalid
  'buf': Expected Lua number` thrown repeatedly inside a self-rescheduling
  `vim.schedule` callback, CPU pegged, had to `kill -9` the process.
  Root cause: `nvim_buf_delete(buf, { force = true })` called
  synchronously right after `vim.cmd 'Dashboard'` raced dashboard-nvim's
  own async render of the new buffer. Fixed by switching to
  `vim.bo[buf].buflisted = false` (no delete, no event fired).
- Second run (buflisted-false version): exited in ~2s, output:
  ```
  FT_AFTER_BD=dashboard
  BUFNAME_AFTER_BD=
  DIAG_ENABLED_ON_DASHBOARD=false
  ```

## Acceptance
| Criterion | Evidence |
|---|---|
| 1. Closing the last listed buffer shows the dashboard, not an empty `[No Name]` scratch buffer | Functional check 2nd run: `FT_AFTER_BD=dashboard`, `BUFNAME_AFTER_BD=` (empty tmpfile-derived name gone, dashboard buffer is what's shown) |
| 2. `filetype=dashboard` buffer has diagnostics disabled | Functional check 2nd run: `DIAG_ENABLED_ON_DASHBOARD=false` |
| 3. `./scripts/health.sh` exits clean | `[1/3] ✓ OK`, `[2/3] ✓ OK (49 files)`, `[3/3] → 0 ERROR, 44 WARNING`, `DONE ✓ — không có lỗi` |

## 2-axis check (doctrine/domains/PROJECT.md)
- **VSCode vs Terminal**: unaffected — `dashboard.lua` already starts with
  `if vim.g.vscode ~= nil then return end` (line 5), so the whole file,
  new code included, never loads in VSCode.
- **Windows vs macOS**: only `vim.api.*`/`vim.bo`/`vim.diagnostic`/
  `vim.schedule` calls — no path separators, no hardcoded Unix paths, no
  external tool/`.cmd`/`.bat` spawn. Verified by static read of the diff
  (no OS-specific surface introduced). Actually run only on macOS this
  session — Windows end-to-end run still pending (no Windows machine
  available here).

## Noticed, not done
- Header comment above the `BufDelete` autocmd block already explains the
  new "auto-created scratch buffer" edge case inline; no separate doc
  update needed (not a keymap, not covered by `keymaps-*.md`).

## Seal gate
None — no outward-facing action yet (no commit/push in this pass).
