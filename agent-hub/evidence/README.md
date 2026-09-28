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
- `## Hub bytes before` — the byte count measured at `pick_next` step 7,
  before the diff starts — the verifier re-reads this number when
  writing `worker-runs.log`, don't skip it
- `## Diff` — files | file | why |
- `## Command` — the exact command from `doctrine/MEMORY.md`
  (`./scripts/health.sh`)
- `## Output` — verbatim, no paraphrasing
- `## Acceptance` — a table | Criterion | Evidence | (evidence points to
  a specific line of output — never a bare "tests pass", must cite the
  real `[1/3]`/`[2/3]`/`[3/3]` lines or `Kết quả tổng: PASS`)
- `## Noticed, not done` — things noticed outside scope but not fixed
  on your own
- `## Seal gate` — record the approval if there was an outward-facing
  action, or "none"

## Format — verifier verdict
- Worker · Node · New PM status (PENDING/SEALED/REOPEN)
- `## Isolation proof` — cites whatever makes this a genuinely separate
  subagent spawn (see `recipes/verify_seal.md` step 1b) — not
  technically enforced by a hook, but a missing/suspicious line here is
  itself citeable evidence for a later audit that `NeverVerifyOwnWork`'s
  subagent-isolation step was skipped.
- `## Reasoning` — cite evidence for each criterion
- `## Missing` — only present on REOPEN
- `## Re-run` — `none`/`partial`/`full`, truthfully declared based on
  what was actually done (see "Re-run scope" in `recipes/verify_seal.md`),
  with a reason if not `none`.

## Format — worker-runs.log
- NOT a narrative note like the files above — it's an **append-only
  file, 1 line per implementer or verifier pass that ends**. Written by
  `pick_next.md`/`implement.md`/`verify_seal.md` THEMSELVES — NOT by
  `/todo` — so it runs identically whether the task went through `/todo`
  or through typing `/worker implementer` then `/worker verifier`
  separately by hand.
- 2 line shapes:
  - Implementer log (only on `blocked`/`failed`, never reaching the
    verifier):
    `<ISO timestamp> role=implementer outcome=blocked|failed node=<slug>
    hub_bytes_before=<N> verifier_rerun=n/a`
  - Verifier log (every time there's a verdict — SEAL or REOPEN):
    `<ISO timestamp> role=verifier outcome=SEAL|REOPEN node=<slug>
    rerun=none|partial|full hub_bytes_before=<N> hub_bytes_after=<N>`
  `hub_bytes_*` uses the exact "per-session total" formula from
  `/hub-tokens` (root + doctrine/ + the active diagram + 2 worker
  bundles).
- Each line is 1 round-trip (1 implementer pass → at most 1 verifier
  verdict), NOT 1 node's whole lifetime.
- Cold storage — not re-read in full every worker session. NEVER delete
  an old line, even one recording a single bad run.
- TOKEN DISCIPLINE: when it exceeds ~15KB, move lines older than the
  current work session to `evidence/worker-runs-archive.log` (same
  directory, plain append, create it lazily on first use) — copy each
  line VERBATIM, never reformat/summarize. Checked by `/hub-tokens`.

## Format — ship note
- Node (must already be SEALED before this note can exist) · Branch ·
  Remote
- `## Commands` — the exact commands run: 3 commands (`git add`,
  `git commit`, `git push`), or 4 more (`git checkout`, `git pull`,
  `git merge --no-ff`, `git push`) if ship ran with `--merge`
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
