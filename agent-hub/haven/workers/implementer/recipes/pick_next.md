# Contract
- Input: `{task: string}`
- Output: `{node, diagram, current_state, acceptance: string[],
  files: string[], blocked_by: string|null}`

> [GUARD] If `/boot` already ran in THIS SAME session (same context),
> `NORTHSTAR.md` / `doctrine/MEMORY.md` /
> `doctrine/domains/PROJECT.md` / `haven/diagrams/` are already in
> context verbatim from that — steps 1-2 below ONLY reuse that existing
> content, do NOT `Read` it again (re-reading = duplicating 4 files
> verbatim in the same context, wasted tokens for nothing). Only `Read`
> for real when: (a) `/worker implementer` is called without `/boot`
> having run first this session, or (b) that content is genuinely absent
> or suspected to have changed since it was last read.

## Steps
1. Get the content of `NORTHSTAR.md` + `doctrine/MEMORY.md` +
   `doctrine/domains/PROJECT.md` — reuse from `/boot` if available (see
   the GUARD above), otherwise `Read` fresh.
2. Get the list of EVERY diagram + PM status — reuse from `/boot` if
   available (see the GUARD above), otherwise `Read` fresh. "EVERY
   diagram" means every file WITHOUT `archive` in its name — an archive
   file is cold storage, not re-read here, matching `/boot` step 5's rule
   exactly.
3. Find the earliest PENDING node on the critical path.
4. No match → don't invent work; clearly report "no PENDING node", stop.
5. Quickly self-check the acceptance criteria of the node just picked —
   NOT a verify pass, only blocks starting to code against a criterion
   that could never have been verified in the first place. Check for
   exactly 3 minimal error classes:
   - **Ambiguity**: the criterion uses a vague adjective ("fast",
     "stable", "clean"...) without a specific measurement/test command.
   - **Underspecification**: no clear pass/fail condition (doesn't map to
     any test command in `doctrine/MEMORY.md`).
   - **Coverage gap**: the acceptance criteria don't point to any
     file/anchor that will change.
   Found an error → rewrite the acceptance criteria right on the node
   (clearer wording, a specific test command/measurement added) before
   moving to step 6, don't silently implement against a vague criterion.
   The node's state doesn't change (still PENDING) — this is the
   implementer's own self-check, not a second independent pass/gate, no
   separate evidence (the evidence note in step 9 only needs 1 extra
   line if the acceptance criteria were rewritten:
   `## Acceptance criteria clarified: <before> → <after>`).
6. Locate code anchors via grep — real paths, don't invent them.
7. Declare blockers: fill in whatever `<<FILL>>` is needed in
   `doctrine/MEMORY.md`.
8. Measure `hub_bytes_before` — the total bytes across exactly the 5
   categories `/hub-tokens` calls the "per-session total" (root files,
   `doctrine/`, the active `haven/diagrams/`, 2 worker bundles). Record
   this number in the evidence note at step 9 — this is the real input
   the verifier uses to compute the hub-size diff in `worker-runs.log`.
9. Evidence: write `evidence/implementer/<date>/<slug>-plan.md`,
   including the line `## Hub bytes before: <N>` from step 8 (and the
   acceptance-criteria-clarified line from step 5 if it was edited).

## Hard rules honored
`NodeBeforeCode` | `EvidencePerAction` | `NoSilentFailure`

## Failure branches
| Failure | Handling |
|---|---|
| No diagram yet | Create `haven/diagrams/<slug>.prime-mermaid.md` matching the `dev-loop` format |
| The task is vague | Stop and ask, don't guess |
| Acceptance criteria vague/not measurable (step 5) | Rewrite it right on the node, state it clearly in the evidence — do NOT implement before fixing it |

## Runtime
`/worker implementer "<task>"`. No API key, no network call — Claude Code
IS the runtime.
