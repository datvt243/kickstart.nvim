---
name: todo
description: "Resolve/create a GitHub issue and checkout its dedicated branch, then run implementer then verifier as one command — still two isolated passes internally (verifier as a separate subagent), auto-repeating the implementer pass on REOPEN up to a retry limit. Usage: /todo \"<task>\"|#<issue-number> [--ship]. Stops at SEAL or the retry limit, never auto-commits — unless --ship was passed, in which case it chains a call to /ship after SEAL (which still shows its own git commands and waits for approval, same as running /ship by hand)."
argument-hint: "<task>|#<issue-number> [--ship]"
---

# /todo — resolve issue + branch, then implementer + verifier in one command

## Steps
1. **Resolve issue + checkout branch** (before any worker call):
   1. **Resolve the issue**:
      - Arg matches `^#?\d+$` (issue mode) → `gh issue view <number>
        --json number,title,url`. Not found / `gh` unavailable or
        unauthenticated → stop, report the real error verbatim, don't
        proceed.
      - Otherwise (free-text mode) → `gh issue create --title "<first
        line of the task, truncated>" --body "<full task text>"` to open
        a new issue from it, capture the created `<number>`/`<title>`/
        `<url>` from the command's own output. Failure (no `gh`, not
        authenticated, no remote configured) → stop, report — never
        proceed without an issue, don't silently fall back to
        issue-less behavior.
      - From here on, `<task>` for the rest of this `/todo` run is the
        resolved issue's title + body (full context for implementer/
        verifier), not just the raw CLI arg.
   2. **Compute the branch name**: check `doctrine/domains/PROJECT.md`
      first for a documented branch-naming convention — same freeform
      resolution step 3 below uses for the base branch. If the project
      documents one (e.g. `bug/<n>`/`feature/<n>`), use it exactly.
      Otherwise default to `<number>-<slug>`, where `<slug>` = the first
      3 words of the issue title, lowercased, non-alphanumeric collapsed
      to `-`. E.g. issue #42 "Fix login redirect loop" →
      `42-fix-login-redirect`.
      [added 2026-09-19] This check matters whenever a project has
      hand-patched its own `/ship` (see `ship.md`'s note on hand-patched
      guards) to auto-close issues by parsing the issue number out of a
      specific branch-name pattern (e.g. `bug/<n>`/`feature/<n>`) —
      defaulting to `<number>-<slug>` there instead would silently break
      that auto-close, because the branch `/todo` creates would no longer
      match what the hand-patched `/ship` parses. That convention MUST be
      documented in `doctrine/domains/PROJECT.md` and honored here, not
      left implicit.
   3. **Resolve the base branch**: read `doctrine/domains/PROJECT.md`
      for the project's own branch flow — same freeform resolution
      `/ship`'s `--merge` step already uses for its target branch. Not
      documented / unclear → stop, ask — don't guess a default (same
      principle as `/ship`'s `MergeOnRequest` resolution).
   4. **Sync the base branch first**: `git fetch origin`, `git checkout
      <base>`, `git pull origin <base>` — always do this before branching
      off, so the new branch (and the implementer's starting point) comes
      from real up-to-date code, never a stale local copy. Pull failure/
      conflict → stop, report the real error verbatim, never
      force/stash/discard on the operator's behalf.
   5. **Checkout the issue's branch**: `gh issue develop <number> --list`
      first — a branch already linked to this issue means resuming
      earlier work → checkout that one, then `git pull` on it too (bring
      in any remote updates since last time), never create a second
      branch for the same issue. Otherwise `gh issue develop <number>
      --checkout --base <base> --name <number>-<slug>` — creates the
      branch off the now-synced base from step 4, links it to the issue
      on GitHub, and checks it out, in one real command. Git-level
      failure (dirty tree blocking checkout, base ref not found, etc.) →
      stop, report the real error verbatim — never force/stash/discard on
      the operator's behalf.
   6. **Report** the resolved issue (`#<number>`, URL) and branch name to
      the user before continuing (`ReadBackBeforeClaim` applies to this
      resolution too) — this is a report, not a second approval gate; the
      only real approval gate in this whole chain is `/ship`'s push, at
      "On SEAL" below.
2. **Pass 1 — implementer**: call `/worker implementer "<task>"` exactly
   as that skill defines it, in the current session context (already on
   the branch from step 1). Wait for it to reach
   `sealed_pending_verifier`, `blocked`, or `failed`.
   - `blocked`/`failed` → stop here, report to the user. Don't retry
     blindly — a blocker (e.g. open `<<FILL>>`) needs a human decision,
     not another implementer attempt. `--ship` never fires here — there
     was no SEAL. (The implementer recipe itself already logged this
     outcome to `evidence/worker-runs.log` — `/todo` doesn't do it again.)
3. **Pass 2 — verifier**: call `/worker verifier "<task>"` exactly as that
   skill defines it — this MUST spawn a separate subagent with a blank
   context, reading only the evidence note pass 1 wrote. Never skip this
   isolation "since it's the same `/todo` call" — the isolation is what
   makes the verdict mean anything, and it's identical to what a human
   typing `/worker verifier` by hand would get. (The verifier recipe
   itself already logs the verdict to `evidence/worker-runs.log`.)
4. **On REOPEN**: read the REOPEN reason from the verifier's evidence
   note, then repeat from step 2 — implementer gets the REOPEN note as
   additional context for what to fix. Track the retry count. (Issue and
   branch from step 1 stay the same across REOPEN cycles — never
   re-resolve.)
5. **Retry limit**: default 3 REOPEN cycles. On reaching the limit without
   a SEAL, stop and report the situation to the user (last REOPEN reason,
   how many attempts) instead of trying a 4th time — repeated REOPEN on
   the same node is a signal the task or the approach needs a human look,
   not more automated attempts. `--ship` never fires here either — same
   reason, no SEAL to ship. (Each REOPEN round already has its own logged
   line from step 3/verify_seal — grep the node's slug in
   `worker-runs.log` to see the full retry history.)
6. **On SEAL**: report the result (node, evidence note paths, issue +
   branch from step 1).
   - **`--ship` NOT passed** (default): stop here. Do NOT proceed to
     commit/push — that's `/ship`'s job, a separate explicit step the
     user runs themselves.
   - **`--ship` passed**: immediately call `/ship "<task>"` exactly as
     that skill defines it — do NOT reimplement any of `/ship`'s logic
     here, just invoke it with the task text as the note. `/ship` still
     runs its OWN full contract unmodified: `SealedOnly` (trivially
     satisfied, this SEAL just happened), showing the real `git add`/
     `git commit`/`git push` commands and waiting for operator approval
     before running them, `NoForce`, `ReadBackBeforeClaim`, its own
     evidence note. `--ship` on `/todo` only removes the need to type
     `/ship` as a second command — it does NOT skip `/ship`'s approval
     gate. If the operator wants `--merge` too, they still call
     `/todo "<task>" --ship` and then use `/ship --merge` for a
     subsequent merge, or invoke `/ship` by hand after — `--ship` here
     never implies `--merge`.

## Hard rules honored
`IssueBranchFirst` (resolve/create the GitHub issue and checkout its
dedicated branch before any worker call; branch name and base always
come from the resolved issue + the project's own documented branch flow,
never guessed; base branch always synced — `fetch`+`checkout`+`pull` —
before branching off it, never a stale local copy) |
`NeverVerifyOwnWork` (via the same subagent isolation
`/worker verifier` uses) | whatever `hard_rules` the loaded implementer/
verifier manifests declare | `SealedOnly`/`NoForce`/`ReadBackBeforeClaim`
(transitively, only when `--ship` is passed and only via the real
`/ship` call in step 6 — not reimplemented here).

## Failure branches
| Failure | Handling |
|---|---|
| `#<number>` given but issue not found / `gh` unauthenticated | Stop, report the real `gh` error verbatim |
| Free-text task but `gh issue create` fails (no remote, no auth, etc.) | Stop, report — never proceed without an issue |
| Base branch not clear from `doctrine/domains/PROJECT.md` | Stop, ask — don't guess a default |
| `git fetch`/`checkout <base>`/`pull` fails (dirty tree, diverged history, conflict, no remote, etc.) | Stop, report the real error verbatim — never force/stash/discard on the operator's behalf |
| `gh issue develop`/checkout fails (dirty tree, base ref not found, etc.) | Stop, report the real error verbatim — never force/stash/discard on the operator's behalf |
| Implementer reports `blocked` on pass 1 | Stop immediately, report the blocker — don't loop |
| Retry limit reached still REOPEN | Stop, report attempt count + latest REOPEN reason, hand back to the user |
| Verifier can't find the evidence note from pass 1 | Stop, report — don't guess what pass 1 did |
| `--ship` passed but the loop stopped on `blocked`/`failed`/retry-limit (no SEAL) | Don't call `/ship` — there's nothing sealed to ship |
| `--ship` passed, SEAL reached, but `/ship` itself then refuses (e.g. push rejected, or a project-specific guard in a hand-patched `/ship`) | Report `/ship`'s real failure — the SEAL from step 6 still stands, only the ship step failed |

## Runtime
`/todo "<task>"|#<issue-number> [--ship]`. First resolves (or creates) the
GitHub issue, syncs the resolved base branch (`fetch`+`checkout`+`pull`,
never a stale local copy), then checks out its dedicated
`<number>-<slug>` branch via `gh issue develop` — no worker call happens
before all of this resolves.
Internally the rest is exactly `/worker implementer` then
`/worker verifier` (subagent) run back to back, looped on REOPEN, then —
only if `--ship` was passed and the loop ended in SEAL — a plain call to
`/ship "<task>"`. No separate implementation of the implement/verify/ship
logic here; all three stay owned by their own skill, including the
`worker-runs.log` logging (owned by `/worker`'s own recipes, not `/todo`).
