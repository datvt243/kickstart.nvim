---
name: issues-ls
description: "List open GitHub issues for this repo, if it's hosted on GitHub. Read-only, no side effects. Use when picking the next task or reviewing the backlog."
argument-hint: "[--group] [--state open|closed|all] [gh issue list flags...]"
---

# /issues-ls — list GitHub issues for this repo

Read-only. Lists issues from GitHub if (and only if) this repo's remote is
a GitHub repo — no writes, no approval gate needed.

## Steps
1. **Check the remote is GitHub.** Run `git remote get-url origin` (fall
   back to another remote if `origin` doesn't exist). If it doesn't
   resolve, or the host isn't `github.com`, stop and report "not a GitHub
   repo — skip" — not an error, just nothing to do.
2. **Check `gh` CLI is available and authenticated.** Run `gh auth
   status`. If `gh` isn't installed or isn't authenticated, stop and
   report the exact output plus a one-line hint (`gh auth login`) — don't
   work around it (no calling the GitHub REST API directly with a token).
3. **List issues.** `gh issue list --state open --limit 50 --json
   number,title,labels,state,updatedAt` by default. Remove `--group`
   (alias `--ground`) from `$ARGUMENTS` first — it's this skill's flag
   (step 5), never passed to `gh`. If the remaining `$ARGUMENTS`
   is given, pass it through verbatim as extra flags to `gh issue list`
   instead of `--state open --limit 50` (e.g. `/issues-ls --state all`,
   `/issues-ls --label bug --assignee @me`), still adding the `--json`
   field list above unless the arguments already include their own
   `--json`.
4. **Reclassify OPEN issues already done on the integration branch.**
   Only if this project uses an integration branch separate from the
   default branch (e.g. `staging` → `main`, per
   `agent-hub/doctrine/domains/PROJECT.md`'s git workflow; none → skip
   this step). `Closes #n` only auto-closes on a merge into the *default*
   branch, so an issue merged into `staging` stays GitHub `OPEN` until
   `/release` ships it. Detect that instead of echoing raw state:
   - `gh pr list --base <integration-branch> --state merged --limit 100
     --json number,body,mergedAt`.
   - From each PR body, extract issue numbers with the same pattern
     `/release` uses: `/\b(close[sd]?|fix(e[sd])?|resolve[sd]?)\s+#(\d+)/gi`.
     Non-keyword mentions (e.g. "related to #72") don't count.
   - Any of those still `OPEN` in step 3's listing → display state
     **`done-dev`** (merged into the integration branch, not released
     yet). Everything else keeps its raw state.
5. **Display as tables, one per group**: issue number, title,
   **Priority**, **Status**, labels, state, updated-at.
   - **Group** = the first `[TAG]` in the title that isn't a priority tag
     (`[QC]`, `[TEST]`, `[ENHANCEMENT]`…) — it marks a campaign/feature, so
     related issues (e.g. a QC round's findings) sit together. Each group
     gets its own `### <TAG>` heading + table, in order of first appearance;
     titles without a tag go under `### Other`. No title has a tag →
     one plain table, no headings (besides `done-dev` below). Strip the group tag and the priority tag
     from the Title cell (the heading/Priority column already show them).
   - **`done-dev` issues (step 4) are pulled out of their tag group** into
     one `### done-dev` group, placed after every other group (incl.
     `Other`) — they're finished, not active work. In that group keep the
     group tag in the Title cell (no heading shows it). Only `done-dev`
     issues → that one group, still with its heading.
   - **Issue number** is plain `#123` — no URL column, no markdown link.
   - **Priority**, first match wins:
     1. A `priority: <level>` label (case-insensitive) → Jira's levels
        `Highest`, `High`, `Medium`, `Low`, `Lowest` (e.g. `priority:
        high` → `High`).
     2. A title tag: `[P0]`–`[P4]` → `P0`–`P4`; `[CRITICAL]`/`[HIGH]`/
        `[MEDIUM]`/`[LOW]` → that word lowercased.
     3. A `critical` label → `critical`.
     None → `—`. Leave `priority: *` labels out of the Labels column.
   - **Status** comes from the issue's `status: <value>` label(s) (e.g.
     `status: pending` → `pending`, `status: waiting-backend` →
     `waiting-backend`) — GitHub's own state is only `OPEN`/`CLOSED`, so
     a `status:` label is where finer-grained status lives. None → `—`;
     several → all, comma-separated. Leave `status: *` labels out of the
     Labels column so they aren't listed twice.
   - **State** is raw `OPEN`/`CLOSED`, or `done-dev` per step 4.
   - Don't re-fetch per issue — steps 3-4 already pulled everything.
   - **`--group` (alias `--ground`) → fix-first order.** Same groups and
     columns as above, plus:
     - Untagged issues: group by their first label that isn't
       `priority: *`/`status: *` (e.g. `bug`, `frontend`) instead of
       `Other`; no such label → `Other`.
     - Rank each issue: `Highest`/`P0`/`critical` = 0, `High`/`P1`/`high`
       = 1, `Medium`/`P2`/`medium` = 2, `Low`/`P3`/`low` = 3,
       `Lowest`/`P4` = 4, `—` = 5.
     - Inside a group, sort by rank, then `bug`-labelled first, then
       lowest issue number (oldest) first.
     - Order groups by their best (lowest) rank, ties by issue count
       (more first); `Other` after ranked groups of equal rank;
       `done-dev` stays last.
     - Heading shows the count: `### <TAG> (n)`.
6. **No writes.** Never close/comment/edit/label an issue from this
   command — that's a separate manual `gh issue` call (or `/release`'s
   own issue-closing step), out of scope here. Step 4's `done-dev` is a
   relabel in THIS skill's output only, not a GitHub mutation.

## Runtime
Requires `gh` CLI authenticated against the project's GitHub remote. If
the repo isn't on GitHub, or `gh` isn't set up, report why and stop — no
fallback to scraping or an unauthenticated API call.
