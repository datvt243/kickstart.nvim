> A recipe is SAVED REASONING — good steps meant to replace figuring it
> out from scratch. Next time, just replay it.

## Why they matter (Compounding Intelligence)
"Recipes are capital. Models are fuel." Compounding intelligence doesn't
live in the model — it lives in the recipe that got written down.

## When to write one
Write a recipe when: (1) this task repeats ≥ 2 times, (2) there's a step
that's easy to get wrong/hard to remember, (3) there's a step that took
real debugging effort to figure out, (4) the process is long enough to
be worth saving.

## What they are NOT
Not a fixed action/command in `manifest.yaml` — that's a different
authority. A recipe lives at `haven/workers/<wid>/recipes/*.md`.

## Format (5 mandatory sections)
1. **Contract** — Input, Output, when to use it.
2. **Steps** — numbered, deterministic.
3. **Hard rules honored** — list the related hard rule names.
4. **Failure branches** — a table | Failure | Handling |.
5. **Runtime** — how it's invoked (`/worker <wid> "<task>"`).

## Maintaining them
When a recipe turns out wrong, fix it, and record it in the Corrections
table in the worker's `MEMORY.md` the moment you discover it's wrong.
Don't delete and walk away — fix it and keep the lesson.
