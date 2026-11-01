> the gate.

# Contract
- Input: 1 path to an evidence note under `evidence/implementer/`, OR
  multiple paths (batch), OR `all-pending` (every node currently
  `sealed_pending_verifier` on the active diagram(s) — see "Batch
  verify" below).
- Output: AN ARRAY, 1 element per node: `[{verdict: SEAL|REOPEN, node,
  cited: string[], missing: string[], forbidden_hit: string|null,
  pm_updated: boolean, rerun: none|partial|full, isolation_proof:
  string}, ...]` — `rerun` is a real self-declaration (step 12b),
  `isolation_proof` is a real self-declaration (step 1b), neither
  inferred from outside.
- REFUSAL: if this very session wrote the diff being reviewed → refuse
  immediately: "I wrote this, a separate verifier pass is required."
  (`NeverVerifyOwnWork`) — in a batch, this applies PER NODE: refuse just
  the self-written node, don't cancel the rest of the batch.

## Batch verify
The heaviest cost of a verify pass is NOT the act of verifying itself —
it's reloading the entire bundle + doctrine on every subagent spawn
(~46k-61k tokens/spawn, measured for real in
`improvements/report/usage-audit-2026-09-02.md`). Batch verify pays that
cost **exactly once** for N nodes instead of N times, while changing
NOTHING about the substance of verifying:

- Step 0 (blank context) + step 1 (self-check refusal) + step 1b
  (isolation proof — the SAME spawn covers the whole batch) run EXACTLY
  ONCE for the whole batch — this is the part that gets amortized.
- Steps 2-12b (read the note, check criteria, scan forbidden states,
  verdict, write the verdict, `## Isolation proof`) run REPEATEDLY,
  INDEPENDENTLY, for EACH node — using node A's evidence/reasoning to
  infer node B's verdict is forbidden, even if the two notes look
  similar. Each node still needs its own evidence, its own verdict, its
  own verdict note at step 12 (citing the SAME step-1b isolation proof,
  since it's one spawn for the batch).
- Being in a batch is NEVER an excuse to loosen any criterion in steps
  2-12b — batching only folds the SPAWN COST, never folds or shortens
  the VERDICT.
- `all-pending`: first list every `sealed_pending_verifier` node on the
  active diagram (read the PM status), then process each node through
  the exact procedure above.

## Re-run scope
By default: AUDIT the note, do NOT re-run build/lint/test/scripts from
scratch. `EvidenceOnly` means "don't take reasoning in place of real
evidence" — it does NOT mean "always reproduce evidence by re-running
everything". If the output in the note is already verbatim, not cut/
hidden (step 5 below), the command matches `doctrine/MEMORY.md` (step
4), and it covers every acceptance criterion (step 6) → base the verdict
directly on that note, no re-running at all.

Only re-run (partially or fully) when:
- The note is missing citations, the output looks cut/hidden, or the
  command doesn't match doctrine → REOPEN immediately per steps 4-5,
  don't waste effort re-running an already-broken note "to be sure" —
  REOPEN and let the implementer write a correct note.
- The node is outward-facing or is a `/release` gate — higher risk than
  an ordinary diff, worth the cost of an independent confirmation.
- `doctrine/domains/PROJECT.md` explicitly lists this class of change as
  needing independent re-running (a per-project decision, not the kit's
  default).

Real observation (usage audit 2026-09-02, 3 production hubs): the
verifier re-running the ENTIRE build/lint/test from cold cache for EVERY
node — even a 1-line README fix — doubled (up to 6x in one case, several
parallel subagents) the token cost of every change without ever changing
the SEAL/REOPEN verdict compared to just auditing the note. That's a
reasonable but expensive reading of `EvidenceOnly` when the recipe
doesn't state the boundary clearly — this section locks in that boundary
so every hub doesn't reason about it differently.

## Steps
0. I'm running as a separate subagent (spawned via the Agent tool after
   the implementer finishes) — blank context, don't see the implement
   pass's reasoning. If batch (multiple notes or `all-pending`): this
   step runs once for the whole batch.
1. SELF-CHECK REFUSAL (a secondary layer, for the case of being called
   incorrectly outside the normal flow) — did I write this diff in this
   session? (Batch: applies per node — if any node was self-written,
   refuse just that node, don't cancel the whole batch.)
1b. Record proof this pass is really a separate
   subagent context, not a self-report: cite whatever this invocation was
   actually spawned with that the implementer pass didn't have (e.g. the
   `description`/task string passed to the Agent tool for this spawn, or
   an equivalent fresh identifier this context can see for itself) —
   write it into the verdict note's `## Isolation proof` line (step 12a).
   This does NOT technically block a skipped isolation (no hook enforces
   it) — it only leaves a citeable trail: a missing line, or one
   identical to the implementer's own task string, is itself evidence for
   a later audit that the subagent-spawn rule in `worker/SKILL.md` was
   skipped this round.
2. [LOOP STARTS HERE FOR EACH NODE if batch] Read the NOTE — only the
   note, do NOT open the diff itself directly. (`EvidenceOnly`)
3. Read the NODE — get the acceptance criteria from `haven/diagrams/`,
   the forbidden states from `CLAUDE.md`. [GUARD]
   Don't `Read agent-hub/CLAUDE.md` separately for this — same mechanism
   as `boot/SKILL.md`: the harness auto-injects this file's full content
   into context (a nested-CLAUDE.md `system-reminder`) the moment step 2
   touches anything under `agent-hub/`; reading it again by hand
   duplicates it. Only `Read` it directly if that content is genuinely
   absent from context after step 2.
4. Check whether the command in the note matches `doctrine/MEMORY.md`
   — including its `Typecheck` row (standalone command run, or build run
   for `inside Build`); TS project with no typecheck output → REOPEN,
   `EDIT_UNVERIFIED`. Row has a `baseline:` → the note must cite the
   count; count above it, or an error in a touched file → REOPEN.
5. Check whether the output is cut/hidden (`...`, "truncated") → REOPEN
   if so.
6. Go through the acceptance criteria ONE BY ONE — any missing evidence
   = REOPEN, state it clearly under "missing". Always includes the
   "comments per code-comments.md" row (see that standard's
   Enforcement), even if the node's own criteria don't list it. Also: an open row for the same issue exists on the
   active diagram but the note has no `## Supersedes`/`## Still open`
   line for it → REOPEN (implement step 7b skipped).
7. Scan all 5 forbidden states.
8. Check the SEAL GATE — was approval recorded in the note if the diff
   was outward-facing?
9. Check proportionality — a diff that does more than the node requires
   → REOPEN (`SmallestDiff`).
10. Verdict, exactly one of: SEAL (every criterion has cited evidence) or
    REOPEN (just one important gap is enough).
11. Only if SEAL: update the ratchet/PM status, then COLLAPSE ON SEAL:
   (a) append the node's full row (state now SEALED) verbatim to
   `haven/diagrams/dev-loop-archive.md` (create it from §9️⃣.5 if
   absent); (b) replace the active row with
   `| node | SEALED | <date> — archived, see dev-loop-archive.md.
   Evidence: <this verdict note path> |`; (c) if the active PM status
   now holds more than 20 such pointer rows, delete the oldest ones
   (their full row already lives in the archive); (d) for each row the
   note lists under `## Supersedes`: append it verbatim to the archive
   under a heading `## Superseded by \`<this node>\` (<date>)`, then
   delete it from the active file — no pointer (this node's row is the
   trail). Part of SEAL itself,
   not a separate maintenance pass — the acceptance criteria written on
   the node during implementation stop costing boot tokens the moment
   the node is sealed.
12. Write the verdict to
    `evidence/verifier/<date>/<slug>-{seal|reopen}.md`.
12a. In that note, include the `## Isolation proof`
   line from step 1b.
12b. In the verdict note, truthfully declare 1 line
   `## Re-run`: `none` (audit-only, the correct default per "Re-run
   scope"), `partial` (re-ran part of it — name exactly which command),
   or `full` (re-ran the entire build/lint/test) — ALWAYS with a reason
   matching one of the 3 exception cases in "Re-run scope" if it's not
   `none`. Declaring it wrong (e.g. writing `none` despite having
   re-run) corrupts the duplicate-detection data at step 13 — not a
   "just for show" field.
13. Append 1 line to `evidence/worker-runs.log`
   (create the file if it doesn't exist) — [REPEAT FOR EACH NODE if
   batch, 1 line per node, loop ends here]: take `hub_bytes_before` from
   the `## Hub bytes before` line in the implementer's note (already
   read in step 2, reuse it — don't read it again); measure
   `hub_bytes_after` yourself with the exact command in
   `evidence/README.md` (Format — worker-runs.log), measured AFTER updating PM status in step
   11 if SEALed. Format:
   ```
   <ISO timestamp> role=verifier outcome=SEAL|REOPEN node=<slug>
   rerun=none|partial|full hub_bytes_before=<N> hub_bytes_after=<N>
   ```
   Runs identically whether the verifier is called via `/todo` or by
   typing `/worker verifier` separately by hand — logging doesn't depend
   on how it's invoked, since it lives directly in this recipe, not in
   `/todo`. NEVER edit/delete an old line in this file, only append (the
   same principle as every other file in `evidence/`).

## Hard rules honored
`NeverVerifyOwnWork` | `EvidenceOnly` | `VerdictOnly` | `RatchetOnly`

## Failure branches
| Failure | Handling |
|---|---|
| No evidence note | REOPEN, `NO_EVIDENCE` |
| The node doesn't exist on any diagram | `grep` its slug in `dev-loop-archive.md` first — found SEALED there → treat as "already SEALED" below; otherwise REOPEN, `forbidden_hit: node_unknown` |
| The node is already SEALED | Don't overwrite it — must be a new node |

## Runtime
`/worker verifier "<task or note>"` — runs as a separate subagent via the
Agent tool, never the same context as the implementer pass.

## Project extensions
- Re-run trigger specific to this repo: an outward-facing node (plugin
  install, `init.lua` structural change) is worth an independent
  `./scripts/health.sh` run.
- Keymap change → the note confirms `keymaps-terminal.md`/
  `keymaps-vscode.md` were updated; plugin change → the 2-axis check
  (VSCode vs Terminal, Windows vs macOS) is recorded, not just asserted.
  Missing → REOPEN.
