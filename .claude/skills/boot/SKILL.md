---
name: boot
description: "Orientation for the nvim-config agent-hub. Read NORTHSTAR, doctrine, diagrams, and the most recent evidence notes; report a 6-line status. Use at the very start of every working session on this project, even for small edits. Makes NO changes."
---

# /boot — 60-second orientation

You are in a READ role here, not a worker role. Do not modify any file
during this step — read and report only.

## Steps (exact order, don't skip any)
1. Read `agent-hub/NORTHSTAR.md`.
2. Recall the 5/6 forbidden states and the seal gate from `agent-hub/CLAUDE.md`
   — [GUARD, added 2026-08-30] don't explicitly `cat`/`Read` it yourself:
   the harness auto-injects this file's full content as a nested-CLAUDE.md
   `<system-reminder>` the moment step 1 touches anything under
   `agent-hub/`, so an explicit read here just duplicates the same content
   a second time in context. Read it directly only if that auto-injection
   didn't happen this session (e.g. it's missing from context after step 1).
3. Read `agent-hub/doctrine/MEMORY.md` — get the repo path and exact
   commands (test/build/dev — report any `<<FILL>>` still open).
4. Read `agent-hub/doctrine/domains/PROJECT.md` — especially the Traps
   table, don't repeat a known bug.
5. Read every file in `agent-hub/haven/diagrams/` EXCEPT any file whose
   name contains `archive` (`dev-loop-archive.md`,
   `dev-loop-archive-2026-08.md`...) — those are cold storage by design
   (see the diagram file's own token-discipline note + `hub-tokens.md`),
   reading them here every session defeats the point of archiving. List
   nodes + current PM status from the non-archive file(s) only.
   [added 2026-09-02] EXCEPTION — if `haven/diagrams/index.md` exists
   (opt-in epic sharding, see `kit/agent-hub-templates.md` §9️⃣.3), read
   ONLY `index.md` + the epic file(s) marked `active: true` in it, not
   every epic. Report node counts from those only; other epics exist but
   are out of scope for this session's status line.
6. Read `agent-hub/haven/workers/` — confirm there are exactly 2 workers:
   implementer, verifier.
7. Read at most the 5 most recent evidence notes (newest file by date) in
   `agent-hub/evidence/implementer/` and `agent-hub/evidence/verifier/`. If
   a directory is empty, note "no evidence notes yet". To list them, use
   `find <dir> -mindepth 2 -maxdepth 2 -type f -name "*.md" -exec ls -t {} + | head -5`
   — note `-mindepth 2`: real evidence notes live one level deeper than
   `<dir>` itself, under a per-date subfolder (`evidence/implementer/
   <date>/*.md`), not directly inside it; `-maxdepth 1` here always
   returns zero results.
   — [GUARD, added 2026-08-30] NOT `ls -lat <dir>` directly: observed
   returning the wrong directory's listing (e.g. the repo root instead of
   the target `evidence/` subfolder) in a real sandboxed session — a
   shell/alias quirk, not a project-specific issue. `find` is the
   proven-reliable form; use it for any other "list files by recency in a
   directory" step this hub ever needs, not just this one.

## Report format — EXACTLY 6 lines, no more, no less
```
🎯 Northstar: <one sentence from NORTHSTAR.md>
✅ Forbidden: <none active | name of the active state, if any>
📊 Diagrams: <N nodes = X sealed, Y pending, Z in_progress>
🔧 Workers: implementer, verifier
📝 Last action: <node — SEAL|REOPEN, date, short quote from the latest evidence note, or "none yet">
🚧 Blockers: <list of open <<FILL>> in doctrine/MEMORY.md or doctrine/domains/PROJECT.md, or "none">
```

## Rules
- Do NOT re-scan the whole source tree — the doctrine already holds the
  ground truth you need.
- Do NOT fill in `<<FILL>>` values yourself during `/boot` — just report
  them as a blocker.
- If a load-bearing file (`NORTHSTAR.md`, `doctrine/MEMORY.md`,
  `doctrine/domains/PROJECT.md`, `haven/diagrams/dev-loop.prime-mermaid.md`)
  can't be read, stop immediately and report the error instead of guessing
  its content.
- After the report, be ready to take `/worker implementer "<task>"`,
  `/worker verifier "<task>"`, `/todo "<task>"` (or `/todo #<issue>`), or
  `/ship`.
- If step 5 flags the active diagram over ~15KB (or `/hub-tokens` reports
  it), that's a real signal to run an archive pass — see the diagram
  file's own token-discipline note. `/boot` itself never edits anything;
  archiving is a separate, explicit action.
