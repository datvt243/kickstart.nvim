# 2026-10-03 — claudecode-reset-on-project-switch — plan

- Worker: implementer
- Node: `claudecode-reset-on-project-switch` (DRAFT, created this pass —
  no prior node existed for this task)
- Issue: #3 — https://github.com/datvt243/kickstart.nvim/issues/3
- Branch: `3-claude-code-giu`

## Task
Claude Code (claudecode.nvim) keeps the old project's terminal
session/cwd alive after switching project via `<leader>sp`
(project.nvim). Root cause (from the issue, confirmed by reading
`claudecode.nvim`'s own source at
`~/.local/share/nvim/site/pack/core/opt/claudecode.nvim/lua/claudecode/`):
`terminal.lua`'s `build_config()` re-resolves `cwd` from
`vim.fn.getcwd()` on every open, but `terminal/native.lua`'s
`open_terminal()` checks module-local `is_valid()` first — if the old
terminal buffer/job is still alive (even hidden via `bufhidden='hide'`),
it just refocuses the old buffer and returns, never respawning the job
with the new cwd.

## Starting point
A fix was already present as an **uncommitted diff** on `master` before
this `/todo` run started (confirmed with the operator before proceeding
— chosen option: "Use it as the implementer's starting point"). This
pass reviews/hardens that diff rather than writing a new one from
scratch, per `SmallestDiff`.

## Acceptance criteria (self-checked per `pick_next` step 5 — no
ambiguity/underspecification/coverage-gap found, criteria kept as-is)
1. `./scripts/health.sh` exits 0 clean, same baseline warning count as
   the last sealed run (44 WARNING, 0 ERROR per
   `evidence/verifier/2026-09-28/dashboard-exclude-indent-guides-seal.md`)
   — no new warning/error introduced.
2. On a global-scope `DirChanged` (the scope `project.nvim` actually
   uses — see `lua/custom/plugins/tools/project.lua`'s own comment:
   "project.nvim đổi cwd bằng lệnh `cd` (scope mặc định 'global')"),
   when the claudecode terminal is active, the stale terminal
   buffer+job gets force-deleted so the next `<leader>cc` spawns a
   fresh job bound to the new cwd — verified functionally, not just by
   code reading (see "Functional check" below).
3. 2-axis check (`doctrine/domains/PROJECT.md`):
   - VSCode vs Terminal: the whole file is already guarded by
     `if vim.g.vscode ~= nil then return end` (line 4, pre-existing,
     unchanged) — the new autocmd is terminal-only by inheritance, never
     loads under vscode-neovim.
   - Windows vs macOS: diff is pure Neovim Lua API calls
     (`nvim_create_autocmd`, `nvim_create_augroup`, `nvim_buf_delete`,
     `require`) — no path separators, no hardcoded Unix paths, no
     OS-only external tool, no `.cmd`/`.bat` spawn. Static-analysis
     clean on both OSes; Windows end-to-end run still pending (no
     Windows machine available this session).
4. No keymap added/changed in this diff → no
   `keymaps-terminal.md`/`keymaps-vscode.md` update required.

## Code anchors (grep-verified, real paths)
- `lua/custom/plugins/tools/claudecode.lua` — file being changed.
- `~/.local/share/nvim/site/pack/core/opt/claudecode.nvim/lua/claudecode/terminal.lua:650-652`
  — `M.get_active_terminal_bufnr()` is real, provider-agnostic
  (delegates to `get_provider().get_active_bufnr()`; returns `nil` for
  providers with no managed buffer, e.g. `external`/`none`).
- `~/.local/share/nvim/site/pack/core/opt/claudecode.nvim/lua/claudecode/terminal/native.lua:17-28`
  — `is_valid()` self-heals: if the tracked `bufnr` is no longer a valid
  buffer, it calls `cleanup_state()` (resets `bufnr`/`winid`/`jobid` to
  `nil`) before returning `false`. So even bypassing the provider's own
  `M.close()` (which only closes the window, see below) by directly
  force-deleting the buffer is safe — the next `is_valid()` call
  self-heals the module state, no stale-state bug.
- `native.lua:155-164` (`close_terminal()`, called by `M.close()`) —
  only does `nvim_win_close(winid, true)` + `cleanup_state()`. It does
  **not** kill the job/buffer — the hidden buffer+job would leak
  (orphaned, untracked) if we called the official `M.close()` API
  instead of force-deleting the buffer directly. Force-deleting the
  buffer (what the diff does) is actually the more correct fix for the
  issue's literal ask ("tự đóng/kill terminal cũ") — confirmed
  empirically below.
- `lua/custom/plugins/tools/project.lua:18-31` — the established
  codebase pattern for this exact scenario (DirChanged, `global` scope
  filter, own augroup) that the new autocmd follows for consistency.

## Hub bytes before
43177 (root 4942 + doctrine 14295 + active diagram 2999 + 2 worker
bundles 20941 — the 5 categories `/hub-tokens` sums as "per-session
total").
