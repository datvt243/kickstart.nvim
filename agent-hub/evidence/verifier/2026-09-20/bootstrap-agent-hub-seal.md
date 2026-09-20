# 2026-09-20 — bootstrap-agent-hub

- Worker: verifier
- Node: `bootstrap-agent-hub`
- New PM status: SEALED (was PENDING)

## Isolation proof
Genuinely separate subagent spawn: launched via the Agent tool with a
blank context (no prior conversation history, no memory of the
implementer pass's reasoning). The spawn prompt I received opens "You
are being spawned as the `verifier` worker for a one-person dev hub...
You have zero prior context" — a distinct spawn description, not the
implementer's task string ("bootstrap agent-hub: thêm thư mục agent-hub
(doctrine, haven, evidence) vào repo"). I only learned the implementer's
reasoning by reading its evidence notes from disk in this pass, per
`EvidenceOnly`.

## Reasoning
Checked each acceptance-criteria row in
`evidence/implementer/2026-09-20/bootstrap-agent-hub-diff.md` against
independently-gathered evidence:

1. "No code leaked into `haven/`" — re-ran
   `find agent-hub/haven -type f ! -name "*.md" ! -name "*.yaml" ! -name "*.yml"`
   myself: empty output, exit 0. Matches the note's claim (CODE_IN_HAVEN
   clear).
2. "Adding `agent-hub/` doesn't break the Neovim config" — note cites
   `./scripts/health.sh` output verbatim: `[1/3] ✓ OK`, `[2/3] ✓ OK (49
   files)`, `[3/3] → 0 ERROR, 44 WARNING`, `DONE ✓ — không có lỗi`. Command
   matches `doctrine/MEMORY.md`'s exact test command. Output has no `...`/
   "truncated" markers. Per `recipes/verify_seal.md`'s "Re-run scope":
   this node is not outward-facing (no commit/push happened in this
   pass), not a plugin install, not an `init.lua` structural change, and
   `doctrine/domains/PROJECT.md` doesn't list this class of change as
   needing independent re-run — so audited the note as-is, did not
   re-run `health.sh` from scratch.
3. "`evidence/` stays committed, only scratch/temp ignored" — read
   `agent-hub/.gitignore` myself: `*.tmp`, `*.scratch`, `.DS_Store` only,
   with a comment confirming `evidence/` is not ignored. Matches the
   note's claim verbatim.
4. "A real node exists on the diagram before this pass reports done" —
   read `haven/diagrams/dev-loop.prime-mermaid.md` myself before editing
   it: PM table held `| bootstrap-agent-hub | PENDING | add agent-hub/
   scaffold (doctrine, haven, evidence) to the code repo as tracked,
   committed files |`. Confirms the node was real (not the unfilled
   `<<FILL>>` template) at implement time.

2-axis check (VSCode/Terminal, Windows/macOS): correctly N/A — no
`lua/`/plugin file touched, `agent-hub/` is pure Markdown/YAML, doesn't
load in Neovim. Keymap doc sync (`keymaps-terminal.md`/
`keymaps-vscode.md`): N/A, no keymap touched.

Forbidden states scanned: `ADHOC_WORK` no (node existed pre-diff,
evidence written); `NO_EVIDENCE` no (plan + diff notes present);
`EDIT_UNVERIFIED` no (health.sh output read back, cited with specific
lines); `CODE_IN_HAVEN` no (independently confirmed above);
`DIAGRAM_DRIFT` no — this SEAL is what brings PM status in sync now.

Seal gate: correctly "none" in the note — no outward-facing action
(commit/push/publish/delete) was taken in the implement pass; the actual
commit/push is deferred to the separate `/ship` gate, per
`doctrine/MEMORY.md`.

Proportionality (`SmallestDiff`): diff is minimal — one PM-table
template row filled in, no extra refactoring.

All 4 acceptance criteria have cited, independently-checked evidence.
No forbidden state hit. Verdict: **SEAL**.

## Re-run
`partial` — re-ran the `find agent-hub/haven ...` command myself (cheap,
independent confirmation of a specific cited claim). Did NOT re-run
`./scripts/health.sh` from scratch: per "Re-run scope" in
`recipes/verify_seal.md`, this node doesn't meet any of the three
re-run-full exceptions (not outward-facing, not a plugin/`init.lua`
change, not flagged in `PROJECT.md`), and the note's health.sh output
was verbatim, uncut, and matched the doctrine command — so audited
directly.
