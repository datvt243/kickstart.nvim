---
name: persona-load
description: "Load an on-demand expert-persona or a named panel from this project's own persona library (outside agent-hub/), printing the loader's SEALED output for the current worker session to read. Advisory only, read-only, no side effects."
argument-hint: "<category>/<name> | -p <panel> | -l [category]"
---

# /persona-load — load an expert persona or panel on demand

Read-only. Wraps this project's own `scripts/load_persona.sh` (lives in
the code repo, NOT in `agent-hub/` — a persona loader is code, and
`CODE_IN_HAVEN` forbids code inside `haven/`). Prints one persona or a
whole panel so the current implementer/verifier pass can borrow that
expert's judgment on a domain-specific question — advisory only, never a
substitute for real evidence.

## Why this exists
A persona is a high-precision pointer into the model's latent space:
naming a real expert activates a cluster of domain knowledge that would
otherwise take paragraphs to restate. Loading ALL personas up front gives
zero lift and wastes tokens (empirically, per the persona-system brief
this skill implements) — this command is the on-demand hook so a worker
only pays for the 1 persona (or panel of 2-4) actually relevant to the
task at hand.

## Steps
1. **Locate the loader.** Check `scripts/load_persona.sh` exists at the
   project root (or whatever `<<root>>` this project declared in
   `doctrine/domains/PROJECT.md`, if it did). If it doesn't exist, stop
   and report: "persona system not set up in this project — build it
   first via `/worker implementer` using the persona-system brief, then
   retry" — never fabricate a persona inline as a fallback.
2. **Parse `$ARGUMENTS`**:
   - `<category>/<name>` → load that one persona file.
   - `-p <panel>` → load every member of that named panel (2-4 files).
   - `-l [category]` → list available personas (all, or filtered to one
     category) instead of loading content — for browsing.
   - No/invalid arguments → run `scripts/load_persona.sh -h` and print
     its usage output verbatim, don't invent your own usage text.
3. **Run the loader for real** (`scripts/load_persona.sh <args>`), READ
   BACK its stdout verbatim — this includes the `=== SEAL ===` header +
   sha256 the script itself prints. Never paraphrase a persona's content
   into your own summary; print what the script actually returned.
4. **Use the result as a lens, not a ruling.** Whatever the loaded
   persona/panel says informs the current implementer's or verifier's
   judgment on a domain-specific question. It NEVER overrides a hard rule
   (`TestsBeforeDone`, `EvidencePerAction`, `NeverVerifyOwnWork`, the 5
   forbidden states, this project's own `doctrine/`) and never counts as
   evidence by itself — a verifier still needs a real cited test/output
   to SEAL; "persona X approved this" is not an acceptance criterion.

## Hard rules honored
- `PersonaAsLensNotAuthority` — a persona/panel informs judgment, never
  grants capability, never overrides `doctrine/`/the 5 forbidden
  states/a safety file, never substitutes for real evidence. Layering:
  `<<project's safety file>> > agent-hub doctrine > repo conventions >
  persona`.
- `CodeStaysOutOfHaven` — the loader script and persona library live in
  the project's own code tree, never inside `agent-hub/haven/` or
  `agent-hub/doctrine/` (would trip `CODE_IN_HAVEN`, and would silently
  inflate the recurring per-session token cost `/hub-tokens` tracks).
- `ReadBackBeforeClaim` — always print the loader's real stdout, never a
  paraphrase of what a persona file "probably says".

## Failure branches
| Failure | Handling |
|---|---|
| `scripts/load_persona.sh` missing | Report "not set up yet", point at building it via `/worker implementer`, stop — don't invent persona content inline |
| Requested `<category>/<name>` or panel not found | Let the loader's own "fail loudly with a suggestion" behavior surface — print its real stderr, don't guess a substitute persona |
| Loader script errors out (bad permissions, syntax) | Report the real error verbatim, don't retry with `sudo`/`chmod` or work around it silently |

## Runtime
`/persona-load <category>/<name>` — load one persona.
`/persona-load -p <panel>` — load a whole panel.
`/persona-load -l [category]` — list available personas.
Requires the project to already have its persona system built (loader +
library in its own code tree — see `doctrine/domains/PROJECT.md` for this
project's `<<root>>`/safety-file names if declared there). Building that
system the first time is a normal code change — run it through
`/worker implementer "build the on-demand expert-persona system"` like
any other task, not through this command.
