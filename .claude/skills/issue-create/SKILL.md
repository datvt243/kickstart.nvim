---
name: issue-create
description: "Create a GitHub issue in this repo. Drafts title/body, shows the exact gh command, waits for approval before creating."
argument-hint: "\"<what the issue is about>\" [--label x] [--assignee @me] [--yes]"
disable-model-invocation: true
---

# /issue-create — create a GitHub issue for this repo

Outward-facing: creating an issue publishes to GitHub. Draft first, show
the exact command, wait for explicit approval, then run — same gate as
`/ship`. `--yes` in `$ARGUMENTS` = the user pre-approved this one call:
still show everything, but create without waiting.

## Steps
1. **Check the remote is GitHub.** `git remote get-url origin` (fall back
   to another remote if `origin` doesn't exist). Missing, or host isn't
   `github.com` → stop, report "not a GitHub repo", nothing to do.
2. **Check `gh` is available and authenticated.** `gh auth status`. Not
   installed / not authenticated → stop, report the exact output plus a
   one-line hint (`gh auth login`). No workaround (no raw REST call with a
   token).
3. **Need a description.** `$ARGUMENTS` empty and nothing in the current
   conversation says what the issue is → ask, don't invent one.
4. **Draft the issue** from `$ARGUMENTS` (plus relevant conversation
   context, e.g. a bug just found):
   - **Title**: one line, specific, ≤ 80 chars.
   - **Body**: short sections as fit — Summary, Steps to reproduce /
     Context, Expected vs actual, Acceptance criteria. Facts only; no
     secrets, tokens, or private data.
   - **Labels**: only flags the user passed, or labels that already exist
     (`gh label list --limit 100`). Never create new labels.
   - Pass-through flags in `$ARGUMENTS` (`--label`, `--assignee`,
     `--milestone`, `--project`) are kept verbatim. `--yes` is this
     command's own flag — strip it, never pass it to `gh`.
5. **Show, then wait.** Write the body to a temp file outside the repo
   (never in `agent-hub/`), then print the title, the full body, and the
   exact command:
   `gh issue create --title "<title>" --body-file <tmpfile> [flags...]`
   Stop and wait for explicit approval. Edits requested → redraft, show
   again. Declined → stop, create nothing. `--yes` → skip the wait, go
   straight to step 6 (step 3 still applies: no description → ask).
6. **Create.** Run the exact command shown — nothing added. Report the
   issue number + URL from `gh`'s output. Failure → report the exact
   error, don't retry with different flags on your own.
7. **No other writes.** Never edit/close/comment/label existing issues,
   and never touch code or commit from this skill.

## Runtime
Requires `gh` CLI authenticated against the project's GitHub remote. Not
on GitHub, or `gh` not set up → report why and stop.
