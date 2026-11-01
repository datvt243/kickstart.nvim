> Evidence is who did what and why (`NO_EVIDENCE` if missing). Every
> worker action ends with a note.

## Layout
```
evidence/implementer/<date>/<slug>-plan.md
evidence/implementer/<date>/<slug>-diff.md
evidence/verifier/<date>/<slug>-{seal|reopen}.md
evidence/ship/<date>/<slug>-ship.md
evidence/worker-runs.log
evidence/worker-runs-archive.log (lazily generated — see below)
```
Date in `YYYY-mm-dd` format, slug in kebab-case taken from the task name.

## Format — implementer note
- Title (date - node) · Worker · Version · Node (points to the diagram) ·
  Task (the verbatim prompt)
- `## Hub bytes before` — the byte count measured at
  `pick_next`'s measure step, before the diff starts — the verifier re-reads
  this number when writing `worker-runs.log`, don't skip it
- `## Diff` — files | file | why |
- `## Command` — the exact command(s) from `doctrine/MEMORY.md`, test +
  typecheck (unless `n/a — no TypeScript`)
- `## Output` — verbatim, no paraphrasing
- `## Acceptance` — a table | Criterion | Evidence | (evidence points to
  a specific line of output — never a bare "tests pass", must cite
  "Tests: 42 passed, 42 total"); always has a "comments per
  code-comments.md" row
- `## Supersedes` / `## Still open` — other
  not-yet-SEALED rows for the same issue: retired by this node on SEAL,
  or kept open with a reason (`recipes/implement.md` step 7b); `none` if
  there are none
- `## Noticed, not done` — things noticed outside scope but not fixed
  on your own
- `## Seal gate` — record the approval if there was an outward-facing
  action, or "none"

## Format — verifier verdict
- Worker · Node · New PM status (PENDING/SEALED/REOPEN)
- `## Isolation proof` — cites whatever makes this a genuinely
  separate subagent spawn (see `recipes/verify_seal.md` step 1b) — not
  technically enforced by a hook, but a missing/suspicious line here is
  itself citeable evidence for a later audit that `NeverVerifyOwnWork`'s
  subagent-isolation step was skipped.
- `## Reasoning` — cite evidence for each criterion
- `## Missing` — only present on REOPEN
- `## Re-run` — `none`/`partial`/`full`, truthfully
  declared based on what was actually done (see "Re-run scope" in
  `recipes/verify_seal.md`), with a reason if not `none`. The verifier
  reads this field back itself when writing to `worker-runs.log` (step
  13) — not a decorative field.

## Format — worker-runs.log
- NOT a narrative note like the files above — it's an
  **append-only file, 1 line per implementer or verifier pass that
  ends**. Written by `implement.md`/`verify_seal.md` THEMSELVES (see
  those two recipes) — NOT by `/todo`. So it runs identically whether the
  task went through `/todo` or through typing `/worker implementer` then
  `/worker verifier` separately by hand, or any other order that goes
  through these exact 2 recipes — logging doesn't depend on how it's
  invoked.
- 2 line shapes:
  - Implementer log (only on `blocked`/`failed`, never reaching the
    verifier):
    `<ISO timestamp> role=implementer outcome=blocked|failed node=<slug>
    hub_bytes_before=<N> verifier_rerun=n/a`
  - Verifier log (every time there's a verdict — SEAL or REOPEN):
    `<ISO timestamp> role=verifier outcome=SEAL|REOPEN node=<slug>
    rerun=none|partial|full hub_bytes_before=<N> hub_bytes_after=<N>`
  `hub_bytes_*` = `/hub-tokens`' "per-session total" (root files +
  doctrine/ + the active diagram + 2 worker bundles; no archives, no
  evidence/). Measure with exactly this, from the repo root — never `du`
  or a whole-tree count:
  `(cd agent-hub && { find . -maxdepth 1 -type f \( -name '*.md' -o -name '*.y*ml' \); find doctrine haven/diagrams -type f \( -name '*.md' -o -name '*.y*ml' \) ! -iname '*archive*'; find haven/workers -type f \( -name '*.md' -o -name '*.y*ml' \); } | xargs cat | wc -c)`
- Each line is 1 round-trip (1 implementer pass → at most 1 verifier
  verdict), NOT 1 node's whole lifetime — a node that needs 3 REOPENs
  will have 3 verifier lines sharing the same `node=`, countable by
  grepping the slug.
- **Purpose**: REAL data (not reasoning) to later spot abnormal patterns
  — repeated REOPEN on the same task type, a verifier re-running despite
  the default policy being audit-only, an abnormal jump in hub size
  between two consecutive runs. Not a real token count (there's no API
  that reads that number) — it's an observable proxy, the same
  philosophy as `/hub-tokens`.
- Cold storage — not re-read in full every worker session (unlike
  `doctrine/`, the active `haven/diagrams/`), only opened when someone
  deliberately checks for a pattern. NEVER delete an old line, even one
  recording a single bad run.
- TOKEN DISCIPLINE: unlike `evidence/implementer/` and
  `evidence/verifier/` (opened per-note, never wholesale), some tooling
  may read this file in full to spot patterns — when it exceeds ~15KB,
  move lines older than the current work session to
  `evidence/worker-runs-archive.log` (same directory, plain append,
  create it lazily on first use) — copy each line VERBATIM, never
  reformat/summarize. Checked by `/hub-tokens`. Same "delete nothing"
  rule as the active file — this is a move, not a cleanup.

## Format — ship note
- Node (must already be SEALED before this note can exist) · Branch ·
  Remote
- `## Commands` — the exact commands run: 3 commands (`git add`,
  `git commit`, `git push`), or 4 more (`git checkout`, `git pull`,
  `git merge --no-ff`, `git push`) if ship ran with `--merge`; plus the
  `git checkout -b fix/<node-slug>` if step 2b auto-created a branch, and
  the `git branch -d`/`git push origin --delete` cleanup if step 9 ran
- `## Output` — the verbatim commit hash + push result (and merge if
  any), never paraphrased into a bare "pushed successfully"
- `## Seal gate` — clearly record the approval received before running
  (no approval = this note may not be written) — with `--merge`, this
  approval covers the merge step too, not 2 separate approvals

## The three rules of this directory
1. **VERBATIM, ALWAYS** — never claim anything without real cited
   evidence.
2. **NEVER DELETE** — if a note is wrong, add a correction, don't delete
   it.
3. **BAD NOTES STAY** — a note recording "the task failed" is still
   kept; keeping the trail spotless matters less than preserving
   doctrine's integrity.
