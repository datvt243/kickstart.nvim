---
description: "Promote staging into main: build+lint gate, real merge commit (no squash), bump semver + tag vX.Y.Z, deploy if DEPLOY_HOOK_URL is set, sync the version bump back to staging, close shipped issues. Usage: /release [patch|minor|major]. Invoking this command IS the operator's go-ahead — no separate confirmation prompt, the build+lint gate + branch protection are the real safety net."
argument-hint: "[patch|minor|major]"
---

# /release — promote `staging` into `main`

> Assumes npm + `package.json` semver + GitHub CLI (`gh`) + `staging`/`main`
> both branch-protected (no direct push to either). Adapt the package
> manager / git-host CLI calls if the target project uses a different
> stack — the step order and safety gates below stay the same.

`main` NEVER receives code any other way: no direct push (branch-protected),
no PR straight from a feature/fix branch (those only ever target `staging`).
This command is the ONLY path `staging` → `main`.

## Steps
0. **Pre-flight.** `git fetch origin`. Compare
   `git log origin/main..origin/staging --oneline` — empty means nothing to
   release: say so, stop. Read the current version from `package.json` on
   `origin/main`. `git tag -l` empty → this is the **first-ever release**
   (changes steps 1-3, 6, 9 below).
1. **Determine the version bump.** First-ever release: release the current
   `package.json` version as-is, skip `npm version`/step 3 entirely —
   nothing to bump from. Otherwise: the command argument may be `patch`,
   `minor`, or `major`. If it's none of those, show the commit list from
   step 0 and ask (don't guess a breaking change silently).
2. **Create the release branch** — skip on the first-ever release (PR
   `staging` itself into `main` in step 5 instead). Otherwise: off the
   latest `origin/staging`, `git checkout -b release/vX.Y.Z origin/staging`.
3. **Bump the version** — skipped on the first-ever release. Otherwise:
   `npm version <bump> --no-git-tag-version` (updates `package.json` +
   lockfile together — never hand-edit the JSON). Commit as
   `chore: release vX.Y.Z`. `--no-git-tag-version` on purpose — this
   command creates the real tag itself in step 6, on the `main` merge
   commit, not on the release branch.
4. **Push the release branch** (skip if step 2 was skipped), then verify
   for real before merging anything into production: run the exact
   build/lint (and test, if this project has one) commands from
   `agent-hub/doctrine/MEMORY.md`, read the output back verbatim. Any
   failure → stop, report it plainly, do NOT open the PR/tag/deploy.
5. **Open the release PR.**
   `gh pr create --base main --head release/vX.Y.Z --title "Release vX.Y.Z" --body "<commit list from step 0>"`
   — or `--head staging` directly on the first-ever release.
6. **Merge with a real merge commit, not squash.**
   `gh pr merge <PR#> --merge` — keeps `staging`'s individual commit
   history on `main` for real traceability of what shipped. Add
   `--delete-branch` ONLY if step 2 wasn't skipped — never when the head
   was `staging` directly (that would delete `staging` itself).
7. **Tag.** `git fetch origin main`, then
   `git tag -a vX.Y.Z origin/main -m "Release vX.Y.Z"`,
   `git push origin vX.Y.Z`.
8. **Deploy if configured.** Check `$DEPLOY_HOOK_URL`. Unset → print
   `deploy: not configured (set DEPLOY_HOOK_URL to enable)`, not a failure.
   Set → `curl -fsS -X POST "$DEPLOY_HOOK_URL"`, report the real
   response/status. A deploy failure does NOT undo the merge/tag — the
   release already happened; report it plainly, let the operator retry the
   deploy separately.
9. **Sync the version bump back to `staging`** — skip on the first-ever
   release (`main`/`staging` already identical). Otherwise:
   `gh pr create --base staging --head main --title "chore: sync vX.Y.Z back into staging" --body "..."`,
   then `gh pr merge <PR#> --merge` (no `--delete-branch` — head is `main`,
   never delete it).
10. **Close the issues this release actually shipped.** `Closes #n` only
    auto-closes on a merge to the repo's *default* branch — if feature/fix
    PRs merge into `staging` (not default), those issues stay open until
    the code reaches `main` here. From the commit list in step 0, find the
    issue numbers, `gh issue close <n> --comment "Released to main via <PR URL>, tagged vX.Y.Z."`
    for each one still open.
11. **Report.** New version, tag name + URL, release PR URL + merge commit
    SHA on `main`, sync-back PR URL, deploy result (or "not configured"),
    issues closed.
12. **Return to `staging` as the local working branch.** Always run,
    regardless of step 9: `git fetch origin staging` then
    `git checkout -B staging origin/staging` — this command's git actions
    leave the local checkout on `main` or a temporary `release/vX.Y.Z`
    branch; land back on `staging`, where day-to-day work branches off,
    instead of leaving the operator on a protected/temporary branch.

## Hard rules honored
Build/lint (or test) gate before any merge to `main` (step 4) | real merge
commit, never squash, into `main` (step 6) | never `--force`/direct push to
a protected branch | deploy failure never undoes a completed release (step
8) | invoking this command IS the seal-gate approval for the whole chain —
no separate "show diff, wait" pause between steps.

## Failure branches
| Failure | Handling |
|---|---|
| Nothing to release (`origin/main..origin/staging` empty) | Say so, stop |
| Build or lint fails (step 4) | Stop, report the real output, don't open the PR/tag/deploy |
| Bump type ambiguous and not the first-ever release | Ask (AskUserQuestion), don't guess a breaking change |
| Deploy hook call fails | Report the real response, don't undo the merge/tag — retry deploy separately |
| PR merge blocked (checks pending, conflicts) | Report the real `gh` output, don't force-merge |

## Runtime
`/release [patch|minor|major]`. Requires `gh` CLI authenticated against the
project's git host and `staging`/`main` both branch-protected (set up via
whatever mechanism the target project used — this command only promotes
between them, it doesn't create the branches/protection itself).
