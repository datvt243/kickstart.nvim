---
name: todo
description: "Resolve/create a GitHub issue and checkout its dedicated branch, then run analyst (feat, or fix with no feature doc) → implementer → verifier as one command — still two isolated passes internally (verifier as a separate subagent), auto-repeating the implementer pass on REOPEN up to a retry limit. Usage: /todo \"[task]\"|#[issue-number] [--ship]. Stops at SEAL or the retry limit, never auto-commits — unless --ship was passed, in which case it chains a call to /ship after SEAL (which shows its git commands and runs them at once — passing --ship is the approval)."
argument-hint: "<task>|#<issue-number> [--ship]"
disable-model-invocation: true
---

# /todo — resolve issue + branch, then implementer + verifier in one command

## Steps
1. **Resolve issue + checkout branch** (before any worker call):
   1. **Resolve the issue**:
      - Arg matches `^#?\d+$` (issue mode) → `gh issue view <number>
        --json number,title,url,labels`. Not found / `gh` unavailable or
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
      first for a documented branch-naming convention (a `Branch naming:`
      line, or freeform — same resolution step 3 below uses for the base
      branch). If the project documents one (e.g. `bug/<n>`/
      `feature/<n>`), use it exactly. Otherwise the kit default
      `<type>/<number>-<slug>`:
      - `<type>` ∈ `feat|fix|hotfix|refactor|docs|chore|test`. First
        match wins: issue label (`bug`→`fix`, `enhancement`/`feature`→
        `feat`, `documentation`→`docs`, a label equal to a type → that
        type) → title's first word (`fix`/`bug`→`fix`, `add`/`implement`/
        `support`→`feat`, `refactor`→`refactor`, `doc`/`docs`→`docs`, a
        word equal to a type → that type) → `feat`.
      - `<slug>` = the first 3 words of the issue title, lowercased,
        non-alphanumeric collapsed to `-`, after dropping a leading word
        that only restates `<type>` (`Fix`, `Add`, `feat:`...).
      E.g. issue #42 "Fix login redirect loop" (label `bug`) →
      `fix/42-login-redirect-loop`.
      This check matters whenever a project has
      hand-patched its own `/ship` (see `ship.md`'s note on hand-patched
      guards) to auto-close issues by parsing the issue number out of a
      specific branch-name pattern (e.g. `bug/<n>`/`feature/<n>`) —
      defaulting to the kit pattern there instead would silently break
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
      --checkout --base <base> --name <branch from step 2>` — creates the
      branch off the now-synced base from step 4, links it to the issue
      on GitHub, and checks it out, in one real command. Git-level
      failure (dirty tree blocking checkout, base ref not found, etc.) →
      stop, report the real error verbatim — never force/stash/discard on
      the operator's behalf.
   6. **Report** the resolved issue (`#<number>`, URL) and branch name to
      the user before continuing (`ReadBackBeforeClaim` applies to this
      resolution too) — this is a report, not an approval gate; the only
      approval in this chain is the operator's `/ship`/`--ship`, at
      "On SEAL" below.
1b. **Pass 0 — analyst**: call `/worker analyst "<task>"` (separate
   subagent) when (`<type>` = step 1.2's type rules, applied even when
   the project's own branch pattern named the branch):
   - `<type>` = `feat` — spec mode; skip when resuming (branch already
     linked in step 1.5) and the issue's doc exists with no unanswered
     open question.
   - `<type>` ∈ `fix|hotfix` and `doctrine/features/INDEX.md` has no row
     for the area/issue — backfill mode (`"document the feature touched
     by: <task>"`). A matching row exists → skip.
   - Anything else → skip.
   Outcomes:
   - `spec_ready` / `no_feature` → continue to pass 1.
   - `needs_input` → show its questions to the operator verbatim and
     wait. With the answers, re-run pass 0 (answers passed in). Never
     answer them yourself, never continue to pass 1 with a question open.
   - `blocked` → stop, report.
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
   itself already logs the verdict to `evidence/worker-runs.log`.) Keep
   the verifier's agent id from the Agent tool result — step 4 reuses it.
4. **On REOPEN**: read the REOPEN reason from the verifier's evidence
   note, then repeat from step 2 — implementer gets the REOPEN note as
   additional context for what to fix. Track the retry count. (Issue and
   branch from step 1 stay the same across REOPEN cycles — never
   re-resolve.) Pass 2 of a REOPEN round: resume the SAME verifier with
   `SendMessage` to its agent id — "round <N>: re-read
   `<note path>` from disk, re-run `verify_seal` steps 2-12, write a new
   verdict note + log line" — instead of a fresh spawn. It never saw the
   implementer's reasoning, so isolation holds; it skips the bundle
   reload. Resume fails (no id, agent gone, error) → fresh spawn as in
   step 3.
5. **Retry limit**: default 3 REOPEN cycles. On reaching the limit without
   a SEAL, stop and report the situation to the user (last REOPEN reason,
   how many attempts) instead of trying a 4th time — repeated REOPEN on
   the same node is a signal the task or the approach needs a human look,
   not more automated attempts. `--ship` never fires here either — same
   reason, no SEAL to ship. (Each REOPEN round already has its own logged
   line from step 3/verify_seal — grep the node's slug in
   `worker-runs.log` to see the full retry history.)
6. **On SEAL**: print exactly this report, nothing else (no diff, no
   recap of the work — the evidence note has it):
   ```
   ✅ SEALED <slug> — <task>
   issue #<n> <url> · branch <branch>
   evidence: <note path>[, <note path>…]
   spawns: verifier <N> (<F> fresh, <R> resumed), REOPEN <k>
   next: /ship "<task>"
   ```
   `spawns:` is read back from
   `grep "role=verifier.*node=<slug> " evidence/worker-runs.log`, never
   counted from memory. A REOPEN round logged `fresh` means step 4's
   resume fell back — append ` (fresh: <why>)` to that line. With
   `--ship`, `next:` becomes `next: running /ship "<task>"`.
   Every non-SEAL stop (step 1 failure, `blocked`, `failed`, retry limit)
   uses the same shape:
   ```
   ⛔ STOPPED <slug|-> — <task> (<blocked|failed|retry-limit|issue/branch>)
   issue #<n> <url> · branch <branch>   (omit if step 1 failed)
   reason: <blocker | latest REOPEN reason | real error, verbatim>
   spawns: verifier <N> (<F> fresh, <R> resumed), REOPEN <k>   (omit if no verifier ran)
   next: <the one decision the user must make>
   ```
   - **`--ship` NOT passed** (default): stop here. Do NOT proceed to
     commit/push — that's `/ship`'s job, a separate explicit step the
     user runs themselves.
   - **`--ship` passed**: immediately call `/ship "<task>"` exactly as
     that skill defines it — do NOT reimplement any of `/ship`'s logic
     here, just invoke it with the task text as the note. `/ship` still
     runs its OWN full contract unmodified: `SealedOnly` (trivially
     satisfied, this SEAL just happened), showing the real `git add`/
     `git commit`/`git push` commands then running them at once
     (`AutoCommitNoGate` — `--ship` was the approval), `NoForce`, `ReadBackBeforeClaim`, its own
     evidence note. `--ship` on `/todo` only removes the need to type
     `/ship` as a second command. If the operator wants `--merge` too, they still call
     `/todo "<task>" --ship` and then use `/ship --merge` for a
     subsequent merge, or invoke `/ship` by hand after — `--ship` here
     never implies `--merge`.

## Hard rules honored
`IssueBranchFirst` (resolve/create the GitHub issue and checkout its
dedicated branch before any worker call; branch name and base always
come from the resolved issue + the project's own documented branch flow
— name falls back to the kit's `<type>/<number>-<slug>`, base never
guessed; base branch always synced — `fetch`+`checkout`+`pull` —
before branching off it, never a stale local copy) |
`NeverVerifyOwnWork` (via the same subagent isolation
`/worker verifier` uses) | `AskDontGuess` (pass 0 questions go to the
operator, never answered by `/todo`) | whatever `hard_rules` the loaded implementer/
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
| Analyst returns `needs_input` on pass 0 | Ask the operator, wait, re-run pass 0 with the answers — no pass 1 before that |
| Implementer reports `blocked` on pass 1 | Stop immediately, report the blocker — don't loop |
| Retry limit reached still REOPEN | Stop, report attempt count + latest REOPEN reason, hand back to the user |
| `SendMessage` resume of the verifier fails on a REOPEN round | Fresh verifier spawn as in step 3 — never verify inline |
| Verifier can't find the evidence note from pass 1 | Stop, report — don't guess what pass 1 did |
| `--ship` passed but the loop stopped on `blocked`/`failed`/retry-limit (no SEAL) | Don't call `/ship` — there's nothing sealed to ship |
| `--ship` passed, SEAL reached, but `/ship` itself then refuses (e.g. push rejected, or a project-specific guard in a hand-patched `/ship`) | Report `/ship`'s real failure — the SEAL from step 6 still stands, only the ship step failed |

## Runtime
`/todo "<task>"|#<issue-number> [--ship]`. First resolves (or creates) the
GitHub issue, syncs the resolved base branch (`fetch`+`checkout`+`pull`,
never a stale local copy), then checks out its dedicated
`<type>/<number>-<slug>` branch via `gh issue develop` — no worker call happens
before all of this resolves.
Internally the rest is exactly `/worker analyst` (feat, or fix with no feature doc), `/worker implementer` then
`/worker verifier` (subagent) run back to back, looped on REOPEN, then —
only if `--ship` was passed and the loop ended in SEAL — a plain call to
`/ship "<task>"`. No separate implementation of the implement/verify/ship
logic here; all three stay owned by their own skill, including the
`worker-runs.log` logging (owned by `/worker`'s own recipes, not `/todo`).
