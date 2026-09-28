# 2026-09-28 — dashboard-exclude-indent-guides — SEAL

- Worker: verifier
- Version: 0.1.0
- Node: `dashboard-exclude-indent-guides`
- Verdict: **SEAL**

## Isolation proof
This pass runs as a fresh, separate agent context, spawned with the
task string: `verifier agent-hub/evidence/implementer/2026-09-28/dashboard-exclude-indent-guides-diff.md`
(the coordinator's Agent-tool call, distinct from any implementer task
string). Nothing about the implementer pass's own reasoning was
carried in — the note, node, and diagram were all read fresh from
disk in this pass, not recalled. `NeverVerifyOwnWork` satisfied.

## Source note
`evidence/implementer/2026-09-28/dashboard-exclude-indent-guides-diff.md`

## Command check (`doctrine/MEMORY.md`)
Note's command: `./scripts/health.sh` — matches `doctrine/MEMORY.md`'s
exact test command for this repo. No mismatch.

## Output check
Output block is complete, no `...`/truncation markers:
```
[1/3] load config...
  ✓ OK
[2/3] parse .lua...
  ✓ OK (49 files)
[3/3] checkhealth...
  → 0 ERROR, 44 WARNING

DONE ✓ — không có lỗi
```
44 WARNING cross-checked against the prior sealed baseline in
`evidence/verifier/2026-09-28/dashboard-reopen-and-quiet-seal.md`
(line: "`[3/3] → 0 ERROR, 44 WARNING` ... matches pre-existing baseline")
— same count, not a new warning introduced by this diff.

## Acceptance criteria (from `evidence/implementer/2026-09-28/dashboard-exclude-indent-guides-plan.md`)
| # | Criterion | Cited evidence | Verdict |
|---|---|---|---|
| 1 | `./scripts/health.sh` exits 0 clean | Diff note Output block: `[1/3] ✓ OK`, `[2/3] ✓ OK (49 files)`, `[3/3] → 0 ERROR, 44 WARNING`, `DONE ✓` | met |
| 2 | Dashboard buffer excluded from ibl (`is_buffer_active` → `false`) | Diff note's headless functional check, `/tmp/ibl_check.txt`: `FT=dashboard`, `IBL_ACTIVE=false` | met |
| 3 | Normal buffer unaffected (`is_buffer_active` → `true`) | Diff note's headless functional check, `/tmp/ibl_check2.txt`: `FT=lua`, `IBL_ACTIVE=true` | met |

## Forbidden-state scan (`CLAUDE.md`)
| State | Hit? | Note |
|---|---|---|
| `ADHOC_WORK` | No | Node exists on `haven/diagrams/dev-loop.prime-mermaid.md`, plan note preceded the diff |
| `NO_EVIDENCE` | No | Diff note present with real command output |
| `EDIT_UNVERIFIED` | No | Both acceptance claims backed by actual headless command output, not asserted |
| `CODE_IN_HAVEN` | No | Only real repo file touched: `lua/custom/plugins/editor/indent_line.lua` |
| `DIAGRAM_DRIFT` | No (post-seal) | PM status updated below to close the gap |

## 2-axis check (plugin/config change, `doctrine/domains/PROJECT.md`)
- VSCode vs Terminal: note confirms `indent_line.lua`'s existing guard
  (`if vim.g.vscode ~= nil then return end`, unchanged) keeps this
  terminal-only — recorded, not just asserted.
- Windows vs macOS: note reasons the change is a pure Lua string-list
  literal, no path separators/Unix paths/OS-only tool/`.cmd` spawn —
  static-analysis clean, recorded with specifics rather than a bare
  "should be fine".
- Matches the repo's own recorded trap in `doctrine/domains/PROJECT.md`
  ("Passing a short `exclude.filetypes` list to `ibl.setup()`... always
  pass the FULL default list plus the new filetype") — the diff's
  reasoning for repeating the full default list is exactly this trap,
  correctly applied.

## Keymap doc sync
N/A confirmed — diff touches only ibl's `exclude.filetypes` config, no
`vim.keymap.set` added or changed. No `keymaps-terminal.md`/
`keymaps-vscode.md` update required.

## Seal gate
Diff note declares "None — no commit/push/publish happened in this
pass (local file edits only)". Correct: this is not yet an
outward-facing action (no commit/push in this pass), so no operator
approval was required before this verify step. Push still requires
separate explicit approval per this repo's stricter push rule.

## Proportionality (`SmallestDiff`)
Diff touches exactly one file (`indent_line.lua`), adding only the
`exclude.filetypes` config needed by the task — no unrelated changes.
Proportionate.

## Re-run
`none` — note's citations are complete, not cut/hidden, the command
matches `doctrine/MEMORY.md`, and every acceptance criterion has direct
cited evidence. This is a config tweak to an already-installed plugin
(not a new plugin install, not an `init.lua` structural change), and
`doctrine/domains/PROJECT.md` does not list this change class as
requiring independent re-run — audit-only per "Re-run scope" default.

## PM status update
`haven/diagrams/dev-loop.prime-mermaid.md`: `dashboard-exclude-indent-guides`
moved `IN_PROGRESS` → `SEALED`, pointer updated to this note (forward
move only, `RatchetOnly`).

## Hub bytes
- before (from implementer's plan note): 45485
- after (post PM-status update, per-session total formula from `/hub-tokens`): 46158
