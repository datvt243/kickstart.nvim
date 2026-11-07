# 2026-10-10 — claudecode-disable-track-selection — DIFF

- Worker: implementer
- Version: 0.1.0
- Node: `claudecode-disable-track-selection` (`haven/diagrams/dev-loop.prime-mermaid.md`)
- Issue: #4 — branch `4-neo-tree-chon-file`
- Plan: `evidence/implementer/2026-10-10/claudecode-disable-track-selection-plan.md`
- Task (verbatim): "Issue #4: Neo-tree: chọn file khi đang mở Claude Code thì file hiện vào input của Claude — Khi đang ở nvim Claude Code (claudecode.nvim), rồi chọn 1 file ở neo-tree thì thấy Claude Code hiện file đó ở input — hãy kiểm tra (đây là hành vi mong muốn/tính năng hay lỗi do config, và xử lý nếu cần)."

## Hub bytes before: 46158

## Diff
| File | Why |
|---|---|
| `lua/custom/plugins/tools/claudecode.lua` | Add `track_selection = false` to `local config` + 3-line comment explaining why (operator chose to disable) |
| `agent-hub/haven/diagrams/dev-loop.prime-mermaid.md` | New PM row `claudecode-disable-track-selection` IN_PROGRESS (NodeBeforeCode) |

## Command
`./scripts/health.sh` (repo root)

## Output
```
[1/3] load config...
  ✓ OK
[2/3] parse .lua...
  ✓ OK (49 files)
[3/3] checkhealth...
  → 0 ERROR, 36 WARNING

DONE ✓ — không có lỗi
EXIT=0
```

Headless probe (after change):
`nvim --headless +'lua vim.defer_fn(function() local c=require("claudecode"); io.stdout:write("track_selection="..tostring(c.state.config.track_selection).." tracking_enabled="..tostring(require("claudecode.selection").state.tracking_enabled).."\n"); vim.cmd "qa!" end, 500)'`
```
track_selection=false tracking_enabled=false
[ClaudeCode] [init] [INFO] Claude Code integration stopped
```
Same probe on the stashed baseline (before change):
```
BASELINE track_selection=true tracking_enabled=true
```

## Acceptance
| Criterion | Evidence |
|---|---|
| 1. health.sh exits 0 | `[1/3] ✓ OK`, `[2/3] ✓ OK (49 files)`, `[3/3] → 0 ERROR`, `DONE ✓ — không có lỗi`, `EXIT=0` |
| 2. track_selection false, tracking never enabled | probe: `track_selection=false tracking_enabled=false` (baseline `true`/`true`) |
| 3. No keymap changed | diff touches only the `config` table + comment; no `vim.keymap.set` lines changed |

## 2-axis check
Config-only change on an already-installed, terminal-guarded plugin (`if vim.g.vscode ~= nil then return end`
unchanged). No paths/OS-specific code → Windows/macOS unaffected (static analysis; not run on Windows).

## Noticed, not done
- 36 checkhealth WARNINGs pre-exist (not from this diff).
- `<leader>cs` desc in Neo-tree is just `'Add file'` — not touched.

## Seal gate
none (no outward-facing action)
