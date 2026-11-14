---
name: spec-backfill
description: "Bulk-backfill draft feature docs (doctrine/features/) for features that already exist in the code. Writes only agent-hub docs, never code. Docs stay draft until confirmed via /worker analyst."
argument-hint: "[<area or path to limit the scan>]"
---

# /spec-backfill — write draft specs for existing features

Documents what the code does today, one doc per user-facing feature, so
later bug fixes have a spec to fix toward. Writes only under
`agent-hub/doctrine/features/` and one evidence note — never touches
code (`ADHOC_WORK` does not apply; a code change here would be). Not the
analyst: no subagent and no operator confirmation per doc, so every doc
stays `draft`.

## Steps
1. **Load the format.** Read `agent-hub/doctrine/features/INDEX.md`
   (table + `## Doc format`), `agent-hub/doctrine/domains/PROJECT.md`,
   `agent-hub/doctrine/MEMORY.md`. `INDEX.md` or its `## Doc format`
   missing → stop: "run `/sys` from agent-hub-init first".
2. **List features.** From the code (routes, pages, CLI commands, API
   endpoints, jobs the user sees the effect of), within `$ARGUMENTS` if
   given. One feature = one capability a user can see, not one file.
   Drop every feature that already has a row in `INDEX.md`. Show the
   list (name, slug, anchors) and wait for the operator to confirm or
   trim it. More than ~15 → suggest splitting by area, ask which first.
3. **Write each doc** `agent-hub/doctrine/features/<kebab-slug>.md` in the
   Doc format exactly:
   - `Status: draft` · `Source: backfill from code` · `Anchors:` real
     paths, each confirmed by grep/read.
   - `## Behavior` = what the code does today, numbered, observable.
   - Anything that looks unintended, inconsistent, or untested →
     `## Open questions`, never `## Behavior`. Never guess intent.
   - `## Acceptance criteria`: each one maps to a test command in
     `MEMORY.md` or an exact observable result — no "works"/"fast"/"clean".
   - Plain English, readable by a human who doesn't know the hub.
   - Read code only. No edit outside `agent-hub/doctrine/features/`.
4. **Index.** Add one `INDEX.md` row per doc: `| <Feature> | <slug>.md |
   draft | <area / anchors> | <issues or -> |`. Never edit existing rows.
5. **Evidence.** Write `agent-hub/evidence/spec-backfill/<YYYY-mm-dd>/backfill.md`:
   scope (`$ARGUMENTS` or `all`), docs written, features skipped (already
   indexed or trimmed by the operator), every open question per doc.
6. **Report.** One line "📝 agent-hub: updated" (don't print doc
   content), then: the list of docs written, and every open question
   grouped by doc — those are what the operator needs to answer.
   End with: "Docs are `draft`. To confirm one: `/worker analyst
   \"document <feature>\"`."

## Rules
- Never write `Status: verified` — only the analyst (operator-confirmed)
  or a SEAL may.
- Never overwrite an existing doc or INDEX row; already documented →
  skip.
- No code change, no commit — the operator commits with `/ship` or by
  hand.

## Failure branches
| Failure | Handling |
|---|---|
| `INDEX.md` / `## Doc format` missing | Stop, tell the operator to run `/sys` first |
| No test command in `MEMORY.md` (`<<FILL>>`) | Use exact observable results for criteria; list the gap in the report |
| An anchor can't be confirmed by grep | Leave it out; don't invent paths |
| Feature boundary unclear (one capability or two?) | Ask in step 2, don't decide silently |
