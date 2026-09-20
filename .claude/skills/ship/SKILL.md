---
name: ship
description: "Commit + push a SEALED node — the outward-facing gate at the end of the loop. Usage: /ship \"[note]\" or /ship \"[note]\" --merge[=<branch>] to also merge + push the current branch into a target branch. Always shows the exact git commands and waits for approval before running anything; never --force/--no-verify."
argument-hint: "[note] [--merge[=<branch>]]"
---

# /ship — commit + push a SEALED node

`/ship` is NOT a third worker — it only runs after a verifier has already
SEALED a node. It never replaces the implementer → verifier loop.

> Note: this project already has its own pre-existing
> `.claude/commands/ship.md` (keymap doc sync + commit/push, with a
> `--skip-keymaps` flag) — that is a DIFFERENT command from this one. This
> file is `.claude/skills/ship/SKILL.md`, the hub's own `/ship`. Don't
> merge or confuse the two; they answer to the same word but live at
> different paths with different contracts.

## Steps
1. Read `haven/diagrams/` to find the node matching the changes in the
   working tree. Not **SEALED** (still PENDING/IN_PROGRESS) → stop
   immediately, tell the user to run `/worker verifier` first — never
   commit a node that hasn't gone through verification (hard rule
   `SealedOnly`).
2. Confirm both an implementer AND a verifier evidence note exist for
   that node. Missing either → stop (`NO_EVIDENCE`), don't assume they
   exist.
3. Show `git status` + `git diff --stat` for real, for the **code**
   changes — list the exact files about to be committed, this is what the
   coder actually needs to review. Changes under `agent-hub/` (evidence/,
   haven/diagrams/, doctrine/...) in the same commit do NOT get printed as
   diff/stat, including newly created files — collapse to one line
   `📝 agent-hub: updated`. `git add` still adds the real `agent-hub/`
   files to the commit — only the session display is collapsed, the
   commit scope is unchanged. Never `git add -A`/`git add .` blindly —
   add only the files that belong to this node's scope.
4. Write a Conventional Commits message (`type(scope): summary`) sourced
   from the real evidence note content — don't invent detail that isn't
   in the evidence.
5. **SEAL GATE**: stop, show the exact commands about to run
   (`git add ...`, `git commit -m "..."`, `git push`) + target
   branch/remote, wait for explicit operator approval. No approval = no
   run. Never `--force`, `--no-verify`, or amend a prior commit (hard rule
   `NoForce`). This project's own working rule from the repo's root
   `CLAUDE.md` is stricter than the hub default: only push when
   explicitly asked — if the approval only covers the commit, stop after
   committing and wait for a separate explicit go-ahead to push.
6. After approval: run the commands, READ BACK the output verbatim
   (commit hash, push result) — don't report "pushed" before reading that
   output back (`ReadBackBeforeClaim`, same principle as `EDIT_UNVERIFIED`).
7. Write `evidence/ship/<date>/<slug>-ship.md` citing the real commit hash
   + push output.
8. **If `--merge[=<branch>]` was passed** (rule `MergeOnRequest`):
   determine the target branch — use `<branch>` if given explicitly,
   otherwise the project's main working branch (read
   `doctrine/domains/PROJECT.md`; if that's not clear, stop and ask, don't
   guess). Fold this into the SAME seal gate as step 5 — show the
   additional real commands (`git checkout <branch>`, `git pull`,
   `git merge --no-ff <source>`, `git push`) together with step 5's
   commands, for ONE combined approval (don't ask twice). After approval,
   run them, read back output (`ReadBackBeforeClaim` applies here too),
   and extend the evidence note from step 7 with the merge + push result.

## Hard rules honored
`SealedOnly` | `NoForce` | `ReadBackBeforeClaim` | `MergeOnRequest`
(only when `--merge` is passed)

## Failure branches
| Failure | Handling |
|---|---|
| Node not SEALED | Refuse, point to `/worker verifier` |
| Missing implementer or verifier evidence note | Refuse (`NO_EVIDENCE`) |
| `--merge` target branch ambiguous | Stop, ask — don't guess a default |
| Push rejected (remote ahead, protected branch, etc.) | Report the real error verbatim — never retry with `--force` |

## Runtime
`/ship "[note]"` or `/ship "[note]" --merge[=<branch>]`. Never creates a
branch or opens a PR on its own — default behavior is commit + push the
current branch only; `--merge` adds exactly one merge + push into a target
branch, still no PR.
