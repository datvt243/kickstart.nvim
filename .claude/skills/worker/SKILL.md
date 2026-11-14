---
name: worker
description: "Become a hub worker (analyst, implementer or verifier) and run its recipe against a task. Usage: /worker analyst \"[feature task]\", /worker implementer \"[task]\" or /worker verifier \"[task or evidence note path]\". implementer runs in the current session; analyst and verifier MUST run as separate subagents with a blank context — the verifier never in the same pass that wrote the diff."
argument-hint: <analyst|implementer|verifier> "<task>"
---

# /worker — load a worker bundle and run its recipe

## Input
First token is the worker id (`analyst`, `implementer` or `verifier`), the rest is
the task description (or, for `verifier`, a pointer to the implementer's
evidence note). `verifier` also accepts multiple note
paths (batch) or the keyword `all-pending` (every node currently
`sealed_pending_verifier` on the active diagram) — see "Batch verify" in
`recipes/verify_seal.md`. This only amortizes the one-time context-load
cost across N nodes in a single subagent spawn; each node still gets its
own independent verdict from its own evidence — see the recipe for the
exact boundary (`NeverVerifyOwnWork` unaffected).

## Steps
1. **Load the bundle** at `haven/workers/<wid>/`: `manifest.yaml`,
   `SOUL.md`, `MEMORY.md` (implementer only — analyst/verifier have none),
   `recipes/*.md`. If the bundle is missing or incomplete, stop and report
   — don't improvise a worker identity from scratch.
2. **Become that worker**: adopt the identity in `SOUL.md` for this pass
   only. Don't carry over identity from a previous `/worker` call in the
   same session — each call re-loads and re-adopts from the bundle.
3. **Branch by role**:
   - `analyst`: spawn a **separate subagent** (Agent tool, blank
     context) that loads this bundle and follows `recipes/spec_feature.md`
     — the spec must not be shaped by the session that will implement it.
     Pass the task (issue title + body) and any operator answers from a
     previous `needs_input` round. Returns `spec_ready`, `needs_input`
     (relay its questions to the operator verbatim — never answer them
     yourself) or `blocked`.
   - `implementer`: run in the CURRENT session context. Follow
     `recipes/pick_next.md` then `recipes/implement.md` in order. Stop at
     `sealed_pending_verifier` (or `blocked`/`failed` per the recipe's
     contract) — never self-report `done` or `SEAL`, that's the verifier's
     word only.
   - `verifier`: MUST run as a **separate subagent**, spawned via the
     Agent tool with a blank context — not a continuation of whatever pass
     wrote the diff being verified. Follow `recipes/verify_seal.md`. If
     this call would run in the same context/pass as the implementer that
     just wrote the diff, refuse and spawn the subagent instead — never
     verify inline "for convenience" (`NeverVerifyOwnWork`, hard rule,
     no exceptions). If the input is a batch (multiple notes or
     `all-pending`), spawn exactly ONE subagent for the whole batch — not
     one per node — that's the entire point (see "Batch verify" in the
     recipe); the subagent still produces one independent verdict per
     node internally. `NeverVerifyOwnWork` here is an
     infrastructure constraint, not a promise to self-police — no hook
     technically blocks a skipped spawn. The only real defense is a
     **citeable trail**: `recipes/verify_seal.md` step 1b requires the
     verifier to record proof of this separate spawn into the verdict
     note's `## Isolation proof` line, so a later audit can catch a
     skipped isolation instead of having to trust it happened. Only
     exception to a fresh spawn: `/todo`'s REOPEN rounds resume the same
     verifier subagent (`todo` step 4) — still never the implementer's
     context.
4. **Follow the recipe exactly** — the recipe's own `## Steps` is the
   authority for what happens next, this file only gets you to "loaded
   bundle, in role, running the right recipe". Don't add ad-hoc steps
   outside what the recipe defines.
5. **Exit after the recipe completes** — don't linger in the worker
   identity for unrelated follow-up work in the same session; a new task
   is a new `/worker` call.

## Hard rules honored
`NeverVerifyOwnWork` (verifier isolation) | `NodeBeforeCode` (via
`pick_next`) | whatever the loaded worker's own `manifest.yaml` declares
under `hard_rules`.

## Failure branches
| Failure | Handling |
|---|---|
| Bundle missing/incomplete at `haven/workers/<wid>/` | Stop, report exact missing file — don't fabricate an identity |
| `verifier` called in the same context as the diff's author | Refuse inline, spawn subagent instead |
| `analyst` returns `needs_input` | Show the questions to the operator, stop — re-run `/worker analyst` with the answers |
| Recipe reports `blocked` | Stop, report the blocker verbatim (e.g. open `<<FILL>>`) — don't guess past it |

## Runtime
`/worker implementer "<task>"` runs in the current session.
`/worker analyst "<task>"` spawns a subagent (also used by hand to backfill
a doc: `/worker analyst "document <existing feature>"`).
`/worker verifier "<task>"` spawns a subagent via the Agent tool — no API
key, no external network call, Claude Code's own subagent mechanism IS the
isolation. `/worker verifier all-pending` (or several note paths) spawns
ONE subagent that verifies every queued node independently — use this
after several small implementer passes have piled up, instead of one
`/worker verifier` call per node.
