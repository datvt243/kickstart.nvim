# Contract
- Input: `{task: issue title + body | "document <existing feature>",
  answers?: operator answers to a previous round's open questions}`
- Output: `{status: spec_ready | needs_input | no_feature | blocked, doc,
  questions: string[]}` — `no_feature`: backfill asked for, but the task
  touches no identifiable feature (chore, config, docs) → nothing written

## Steps
0. Separate subagent, blank context (spawned by `/worker analyst` or
   `/todo`). Don't see or carry any implementer reasoning.
1. Read `doctrine/domains/PROJECT.md` (Invariants, Decisions),
   `doctrine/MEMORY.md` (test commands), `doctrine/features/INDEX.md`.
2. Find the feature: an INDEX row matching this area/issue → UPDATE that
   doc (new Behavior items + a `## Changelog` row), never a 2nd doc for
   the same feature. None → new `doctrine/features/<slug>.md` in the format at the bottom of `INDEX.md`.
3. Read the code the feature will touch — grep anchors, existing
   behavior, conventions. Read-only. Backfill mode ("document <feature>"):
   describe what the code does today, mark anything that looks
   unintended as an open question, not as Behavior. `Source: backfill
   from code`. The task is a fix, not a feature → document the feature
   that fix lands in (not the bug); none identifiable → `no_feature`.
4. Write the doc: Goal, Behavior (numbered, observable), Acceptance
   criteria (each one maps to a `doctrine/MEMORY.md` test command or an
   exact observable result — no "fast"/"clean"/"works"), Edge cases,
   Out of scope. `Status: draft`. Add/update its INDEX row. A doc already
   there from outside the analyst (bulk backfill) → treat it as this
   recipe's draft: re-check it against the code, don't rewrite it.
5. Open questions: anything the issue + code + doctrine can't decide
   (behavior choice, scope, UX, data rule). Fill in the operator's
   `answers` if given. Any question still unanswered that changes
   Behavior or Acceptance → `needs_input`, list them. Never pick an
   answer to keep moving. Backfill + every question answered + the
   operator said the doc is right → `Status: verified — confirmed by
   operator <date>, see <this note>` (INDEX row too). A `feat` spec stays
   `draft` — only the SEAL of its node verifies it.
6. Evidence: `evidence/analyst/<date>/<slug>-spec.md` — Task (verbatim),
   Doc path, Sources read (files), Questions + answers, Isolation proof
   (what this spawn got that the main session didn't, as in
   `verify_seal` step 1b).

## Hard rules honored
`AskDontGuess` | `MeasurableCriteria` | `EvidencePerAction` | `NoCode`

## Failure branches
| Failure | Handling |
|---|---|
| Request too vague to write any Behavior | `needs_input` with the questions — no placeholder doc content |
| Request contradicts a PROJECT.md Invariant or a `verified` doc | `needs_input`, cite both — the operator decides |
| No test command fits a criterion (`<<FILL>>` in MEMORY.md) | Write the exact observable result instead; note the gap |

## Runtime
`/worker analyst "<task>"` — separate subagent via the Agent tool. `/todo`
runs it for `feat` (spec) and for `fix`/`hotfix` with no feature doc yet
(backfill).
