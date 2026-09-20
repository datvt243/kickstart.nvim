---
description: "List open GitHub issues for this repo, if it's hosted on GitHub. Read-only, no side effects."
argument-hint: "[--state open|closed|all] [gh issue list flags...]"
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
3. **List issues.** `gh issue list --state open --limit 50` by default.
   If `$ARGUMENTS` is given, pass it through verbatim as extra flags to
   `gh issue list` instead of the defaults (e.g. `/issues-ls --state all`,
   `/issues-ls --label bug --assignee @me`).
4. **Display as a table**: issue number, title, labels, state,
   updated-at, URL — whatever `gh issue list` returns is enough, don't
   reformat or re-fetch per-issue unless the arguments ask for more detail
   (e.g. a `--json` variant).
5. **No writes.** Never close/comment/edit an issue from this command —
   that's a separate manual `gh issue` call (or `/release`'s own
   issue-closing step), out of scope here.

## Runtime
Requires `gh` CLI authenticated against the project's GitHub remote. If
the repo isn't on GitHub, or `gh` isn't set up, report why and stop — no
fallback to scraping or an unauthenticated API call.
