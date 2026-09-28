# 2026-09-20 — bootstrap-agent-hub

- Worker: implementer
- Version: 0.1.0
- Node: `bootstrap-agent-hub`
- Task (verbatim): "bootstrap agent-hub: thêm thư mục agent-hub (doctrine, haven, evidence) vào repo"

## Hub bytes before: 45301

## Diff
No Lua/shell code touched. The diff is the `agent-hub/` scaffold itself
(already present on disk, currently untracked — `git status` at pick_next
time showed it as `?? agent-hub/`), plus one edit made in this pass:

| File | Why |
|---|---|
| `agent-hub/haven/diagrams/dev-loop.prime-mermaid.md` | filled the PM status template row (`<<FILL>>`) with the real `bootstrap-agent-hub` node — `NodeBeforeCode` requires a real node before any implement pass |
| `agent-hub/{README,INDEX,NORTHSTAR,BOOT,CLAUDE}.md`, `agent-hub/doctrine/**`, `agent-hub/haven/workers/**`, `agent-hub/evidence/README.md`, `agent-hub/.gitignore` | pre-existing untracked files written by the operator outside this pass — not authored here, only verified in this pass (see checks below) |

No commit/push happened in this pass — that is the `/ship` skill's job,
gated separately after SEAL (per `doctrine/MEMORY.md`: "the default way to
work" ends at verifier, `/ship` is a distinct, later gate).

## Command
`./scripts/health.sh` (from `doctrine/MEMORY.md`, run from repo root
`/Users/_david/.config/nvim`)

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

## 2-axis check
N/A — no plugin installed/changed, no `lua/` file touched. `agent-hub/`
is pure Markdown/YAML, doesn't load in Neovim, doesn't participate in the
VSCode-vs-Terminal or Windows-vs-macOS axes.

## Acceptance
| Criterion | Evidence |
|---|---|
| No code (`.lua`/`.sh`/`.py`...) leaked into `haven/` (`CODE_IN_HAVEN`) | `find agent-hub/haven -type f ! -name "*.md" ! -name "*.yaml" ! -name "*.yml"` → empty output (checked this pass) |
| Adding `agent-hub/` doesn't break the Neovim config | `./scripts/health.sh` → `[1/3] ✓ OK`, `[2/3] ✓ OK (49 files)`, `[3/3] → 0 ERROR, 44 WARNING`, `DONE ✓ — không có lỗi` (verbatim above) |
| `evidence/` stays committed, only scratch/temp is ignored | `agent-hub/.gitignore` → `*.tmp`, `*.scratch`, `.DS_Store` only; explicit comment confirms `evidence/` is NOT ignored |
| A real node exists on the diagram before this pass reports done (`NodeBeforeCode`) | `haven/diagrams/dev-loop.prime-mermaid.md` PM table row now reads `bootstrap-agent-hub \| PENDING \| ...` (edited this pass, see Diff) |

## Noticed, not done
- The diagram's PM table still has only this one real row — fine for now,
  no archiving needed yet (well under the ~15KB threshold).
- Did not run `/hub-tokens`'s full report (only reused its byte formula
  for `hub_bytes_before`) — out of scope for this node.

## Seal gate
None — no outward-facing action (`commit`/`push`/`publish`/`delete`) taken
in this implement pass. The actual `git add`/`commit`/`push` for
`agent-hub/` will go through the `/ship` skill's own seal gate, after the
verifier SEALs this node.

Status: `sealed_pending_verifier`
