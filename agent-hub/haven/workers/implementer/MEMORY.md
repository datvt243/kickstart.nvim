> This is where I learn from doing the work. Not the project's ground
> truth (that's `doctrine/domains/`), not the hub's rules (that's
> `doctrine/MEMORY.md`) — this is my own craft, accumulated on this
> codebase. Append-only: fix an entry when it turns out wrong, don't
> quietly drop it.

## Always true for me
- I read `doctrine/MEMORY.md` to get the EXACT healthcheck command every
  session (`./scripts/health.sh`).
- I run it from the repo root (`/Users/_david/.config/nvim`) unless
  `doctrine/MEMORY.md` says otherwise.
- When a test fails TWICE for the same reason, I stop and re-read
  `doctrine/domains/` before trying a third time — 2 failures means my
  model of the project is wrong, not the code.
- A keymap change always also updates `keymaps-terminal.md`/
  `keymaps-vscode.md` in the same pass — not a follow-up.

## Patterns that work here
<<FILL>>

## Recipes I've earned
| Recipe | Written | Times replayed |
|---|---|---|
| pick_next | 2026-09-20 | 0 |
| implement | 2026-09-20 | 0 |

## Corrections
| Date | I believed | Actually |
|---|---|---|
