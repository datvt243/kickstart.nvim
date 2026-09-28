---
name: ship
description: "Commit + push a SEALED node — the outward-facing gate at the end of the loop. Usage: /ship \"[note]\" or /ship \"[note]\" --merge[=<branch>] to also merge + push the current branch into a target branch. Commit runs automatically (no gate); push (and merge/cleanup) always shows the exact git commands and waits for approval first; never --force/--no-verify."
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
0. **Branch safety check** (`BranchBeforeCommit`): run
   `git branch --show-current`. If it's already something other than the
   project's main branch (`master`), skip this step — the fix already
   lives on its own branch. If it IS `master` (e.g. the fix was made
   directly via `/worker implementer` without going through `/todo`),
   auto-create and checkout a dedicated branch off `master` for this
   node, **without asking first** — this specific action is local-only
   (no push, no delete, nothing outward-facing), so it doesn't need the
   seal gate:
   ```
   git checkout -b fix/<node-slug> master
   ```
   Report the new branch name to the user (a statement, not a question)
   and continue the rest of this recipe on that branch. `<node-slug>` is
   the node's slug from `haven/diagrams/`.
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
5. **Auto-commit** (`AutoCommitNoGate`, [updated 2026-09-29 per operator
   request] — commit is local-only, not outward-facing, so it no longer
   needs a stop-and-wait): run `git add <scoped files>` then
   `git commit -m "..."` right away, no approval needed first. Still show
   the files staged (step 3's output) and the commit message used, so the
   operator sees what happened — that's a report, not a gate. Never
   `--no-verify`, or amend a prior commit (hard rule `NoForce`).
6. READ BACK the commit output verbatim (commit hash) — don't report
   "committed" before reading that output back (`ReadBackBeforeClaim`,
   same principle as `EDIT_UNVERIFIED`).
7. **PUSH GATE**: stop, show the exact push command about to run
   (`git push` + target branch/remote), wait for explicit operator
   approval. No approval = no push. This project's own working rule from
   the repo's root `CLAUDE.md` is stricter than the hub default: only
   push when explicitly asked — auto-commit (step 5) never implies
   auto-push. After approval, run it, READ BACK the output verbatim
   (push result) before reporting "pushed".
8. Write `evidence/ship/<date>/<slug>-ship.md` citing the real commit hash
   + push output.
9. **If `--merge[=<branch>]` was passed** (rule `MergeOnRequest`):
   determine the target branch — use `<branch>` if given explicitly,
   otherwise the project's main working branch (read
   `doctrine/domains/PROJECT.md`; if that's not clear, stop and ask, don't
   guess). Fold this into the SAME push gate as step 7 — show the
   additional real commands (`git checkout <branch>`, `git pull`,
   `git merge --no-ff <source>`, `git push`) together with step 7's
   command, for ONE combined approval (don't ask twice). After approval,
   run them, read back output (`ReadBackBeforeClaim` applies here too),
   and extend the evidence note from step 8 with the merge + push result.
10. **Post-merge cleanup** (`CleanupFixBranch`, only when step 9 ran AND
   only if the branch being merged is the one step 0 auto-created, i.e.
   name matches `fix/<node-slug>`): once the merge + push in step 9 is
   confirmed successful (real output read back, not assumed), as part of
   the SAME approval already given for step 9 (don't ask a third time):
   ```
   git checkout <target-branch-from-step-9>
   git branch -d fix/<node-slug>
   git push origin --delete fix/<node-slug>   # only if step 7 had pushed this branch to origin
   ```
   Show these commands alongside step 9's commands in the one combined
   push-gate display, so the operator sees the full sequence
   (commit → push → merge → push → cleanup) before approving the push
   side (commit itself already happened per step 5). Record the cleanup
   result in the same evidence note as step 8/9. If the branch being
   merged was NOT one step 0 created (operator was already on a
   pre-existing feature branch), skip this step entirely — never delete a
   branch `/ship` didn't create itself.

## Hard rules honored
`SealedOnly` | `NoForce` | `ReadBackBeforeClaim` | `MergeOnRequest`
(only when `--merge` is passed) | `BranchBeforeCommit` | `AutoCommitNoGate`
| `CleanupFixBranch` (only when `--merge` is passed AND the merged branch
is one `/ship` auto-created in step 0)

## Failure branches
| Failure | Handling |
|---|---|
| Node not SEALED | Refuse, point to `/worker verifier` |
| Missing implementer or verifier evidence note | Refuse (`NO_EVIDENCE`) |
| `--merge` target branch ambiguous | Stop, ask — don't guess a default |
| Push rejected (remote ahead, protected branch, etc.) | Report the real error verbatim — never retry with `--force` |
| Step 0's `git checkout -b` fails (e.g. branch name already exists, dirty tree) | Report the real error verbatim, stop — never force/stash/discard on the operator's behalf |
| Step 5's `git commit` fails (e.g. hook rejects it) | Report the real error verbatim, stop — commit auto-runs but a failure is never silently retried or forced |
| Step 10's branch delete fails (unmerged commits, branch checked out elsewhere) | Report the real error verbatim, leave the branch in place — never `-D` force-delete |

## Runtime
`/ship "[note]"` or `/ship "[note]" --merge[=<branch>]`. Never creates a
branch or opens a PR on its own — default behavior is commit + push the
current branch only; `--merge` adds exactly one merge + push into a target
branch, still no PR. Commit (steps 3-6) runs automatically without a
stop-and-ask; push and everything after it (steps 7, 9, 10) still require
one explicit operator approval per run.
