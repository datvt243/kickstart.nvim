---
name: check-fix
description: "Adopt a bug fix the developer wrote by hand into the hub: check the branch (name, issue link, base it was cut from), review the diff against the feature doc and PROJECT.md, record a diagram node + evidence note, then run the isolated verifier. Report-only — never edits code. Use when a dev fixed an issue themselves instead of via /todo."
argument-hint: "[#issue] [--base=branch]"
---

# /check-fix — check, review and verify a fix the developer wrote by hand

Never edits, stages, commits, checks out, rebases, stashes or force-anything
in the code — every problem is REPORTED with a suggested command, the dev
runs it. Writes only under `agent-hub/`. The verdict comes from the separate
verifier subagent, never from this skill.

## Steps
1. **Issue.** `$ARGUMENTS` `#<n>` → use it. Else parse the number from the
   current branch name, else `gh issue develop --list` matches. None → stop,
   ask. `gh issue view <n> --json title,labels,body,state`. Type per `/todo`
   step 1.2 rules; not `fix`/`hotfix` → ⚠ "feature work goes through
   `/todo`", continue only if the operator says so.
2. **Branch check** (read-only; `git fetch origin` is the only network op).
   Base = `--base=` or `doctrine/domains/PROJECT.md`'s branch flow (same
   resolution as `/todo` step 1.3); unclear → stop, ask. Mark each ✅/⚠/❌:
   - On the base branch itself or detached HEAD → ❌, suggest
     `git switch -c <expected name>`.
   - Name ≠ project convention in `PROJECT.md`, else kit default
     `<type>/<n>-<slug>` (`/todo` step 1.2) → ⚠, show the expected name.
   - Branch not linked to the issue (`gh issue develop <n> --list`) → ⚠
     (`/ship` won't auto-close it).
   - Cut from the wrong base: `git log --oneline origin/<base>..HEAD`; a
     merge commit, or a commit that `git branch -r --contains <sha>` shows
     on another remote branch → ❌, list those commits and the branch they
     came from.
   - Stale base: `git rev-list --count HEAD..origin/<base>` > 0 → ⚠,
     suggest `git rebase origin/<base>`.
   - `git status --short` → record uncommitted files (they're part of the
     fix; not an error).
   Any ❌ → go to step 7 (report), no hub writes.
3. **Spec.** `doctrine/features/INDEX.md` has no row for the area/issue →
   `/worker analyst "document the feature touched by: #<n> <title>"`
   (subagent, backfill mode). `needs_input` → show its questions verbatim,
   wait; never answer them yourself.
4. **Review** the diff = `git diff origin/<base>...HEAD` + `git diff HEAD`.
   - Generic bugs: run Claude Code's built-in `/code-review medium` on
     the current branch — never `--fix`/`--comment`, never `max`/`ultra`.
     Its correctness findings → ❌, its cleanup findings → ⚠. Not
     available → do that pass inline (read touched files in full,
     callers, edge cases).
   - Issue labeled `security` (step 1's labels): also run the built-in
     `/security-review`. Its findings → ❌. Not available → do that pass
     inline (trust boundaries, auth, injection, secrets).
   - Hub checks (what `/code-review` doesn't know), each with
     `file:line`:
     - ❌ doesn't fix the issue's reported bug / fixes a symptom not the
       cause, contradicts the feature doc's `## Behavior` or a
       `PROJECT.md` invariant/trap.
     - ⚠ no test covering the bug, changes outside the issue's scope,
       breaks a `doctrine/standards/` rule.
   Write `evidence/check-fix/<date>/<slug>-review.md` (issue, branch
   check table, findings). Any ❌ → step 7, no node.
5. **Record.** Slug = branch name with `/` → `-`. Run
   `recipes/pick_next.md` steps 1-9 for an explicit task "#<n> <title>
   (manual fix by operator)" — creates or resumes the node, clarifies
   criteria, measures hub bytes. Then `recipes/implement.md` steps 5-10b,
   except 6c (step 4 above is the review)
   (run the exact `MEMORY.md` test + typecheck commands, read output back,
   loop guard, supersedes, write the implementer note per
   `evidence/README.md`) — skip steps 1-4, the code is already written.
   In the note: `## Author: operator (manual fix, adopted by /check-fix)`
   and `## Review` = step 4's `/code-review`/`/security-review` findings
   (none ❌ left) + `<step-4 note path>`. Tests fail → `reopened_by_test`:
   report, stop, no verifier.
6. **Verify.** `/worker verifier "<implementer note path>"` exactly as
   `/todo` pass 2 — separate subagent, blank context. One round only: on
   REOPEN never fix or re-run; report the reason.
7. **Report.** "📝 agent-hub: updated" (if anything was written), then:
   - Branch table (✅/⚠/❌ + suggested command per non-✅ row)
   - Review findings (❌ then ⚠, `file:line`)
   - Verdict: SEAL → "next: `/ship`"; REOPEN → reason + "fix, then
     re-run `/check-fix`"; stopped earlier → which step and why.

## Rules
- Report-only on code and git state: never edit code, never checkout/
  rebase/stash/commit/push. Suggested commands are text for the dev.
- Never self-verify: the SEAL/REOPEN verdict only comes from step 6's
  subagent.
- Re-run after a fix resumes the same node (`pick_next` step 4); new
  evidence notes, never overwrite old ones.

## Failure branches
| Failure | Handling |
|---|---|
| No issue number resolvable | Stop, ask for `#<n>` |
| Base branch not documented in `PROJECT.md` and no `--base=` | Stop, ask; don't guess |
| `gh` missing/unauthenticated | Skip issue-link check (⚠), ask for the issue title/type |
| `git fetch` fails | Stop, report the real error verbatim |
| Analyst `needs_input` | Show questions verbatim, wait |
| `MEMORY.md` test command is `<<FILL>>` | `blocked` per `pick_next` step 7, report |

## Runtime
`/check-fix [#issue] [--base=branch]`. Claude Code is the runtime; `git` and
`gh` are the only external commands.
