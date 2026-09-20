---
name: hub-tokens
description: "Report the token cost of agent-hub/ — how much gets read every worker session (recurring cost) vs cold storage (evidence/, archived diagram/PROJECT.md/log rows) that's only opened on demand. Usage: /hub-tokens. Read-only, makes no changes."
---

# /hub-tokens — measure agent-hub's token cost

Read-only diagnostic. No file changes, no seal gate needed.

## Why this exists
`haven/diagrams/dev-loop.prime-mermaid.md` and `doctrine/domains/
PROJECT.md` are both read in full by every worker session (implementer,
verifier, and every subagent spawned for a `/todo` verify pass re-loads
them from scratch). Left unchecked either grows forever and becomes the
single biggest recurring token cost in the hub — this is what the
`dev-loop-archive.md` / `PROJECT-archive.md` conventions (see each file's
own header note) exist to bound. This command measures whether that's
actually happening, instead of guessing.

There's no exact tokenizer available here — the report uses `bytes / 4` as
a documented, consistent proxy (not a real token count). Good enough to
catch size regressions and compare categories; don't quote it as a real
billed-token number.

## Steps
1. Run this exact script from the repo root (adjust `ROOT` if invoked
   elsewhere — it defaults to the current directory):

```bash
ROOT="."
HUB="$ROOT/agent-hub"

bytes_glob() { find $1 -maxdepth "${2:-99}" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' '; }
bytes_glob_exclude() { find "$1" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) ! -iname "*archive*" 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' '; }
row() { local label="$1" b="$2"; local t=$(( b / 4 )); printf "  %-40s %9d B  ~%8d tok\n" "$label" "$b" "$t"; }
check_threshold_bytes() {
  local label="$1" b="$2" threshold="$3" hint="$4"
  local kb=$(( threshold / 1024 ))
  if [ "$b" -gt "$threshold" ]; then
    echo "  ⚠ $label is ${b}B (>${kb}KB threshold) — $hint"
  else
    echo "  ✓ $label is ${b}B, under the ${kb}KB threshold"
  fi
}
check_threshold() {
  local file="$1" threshold="$2" hint="$3"
  [ -f "$file" ] || return
  local b; b=$(wc -c < "$file" | tr -d ' ')
  check_threshold_bytes "$(basename "$file")" "$b" "$threshold" "$hint"
}

echo "agent-hub token report — $(date +%Y-%m-%d)  [$ROOT]"
echo "==================================================================="
echo "READ EVERY WORKER SESSION (this is the recurring cost):"
ROOT_B=$(bytes_glob "$HUB" 1)
DOCTRINE_B=$(bytes_glob_exclude "$HUB/doctrine")
DIAG_ACTIVE_B=$(bytes_glob_exclude "$HUB/haven/diagrams")
IMPL_B=$(bytes_glob "$HUB/haven/workers/implementer")
VERIF_B=$(bytes_glob "$HUB/haven/workers/verifier")
row "root files (NORTHSTAR/CLAUDE/etc)" "$ROOT_B"
row "doctrine/" "$DOCTRINE_B"
row "haven/diagrams/ (active file only)" "$DIAG_ACTIVE_B"
row "haven/workers/implementer/" "$IMPL_B"
row "haven/workers/verifier/" "$VERIF_B"
SESSION_B=$(( ROOT_B + DOCTRINE_B + DIAG_ACTIVE_B + IMPL_B + VERIF_B ))
row "= per-session total (implementer or verifier boot load)" "$SESSION_B"
echo
echo "COLD STORAGE (opened on demand only, NOT re-read wholesale by"
echo "pick_next/verify_seal — large size here is not a recurring cost):"
ARCHIVE_B=$(find "$HUB/haven/diagrams" -type f -iname "*archive*" 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' ')
DOCTRINE_ARCHIVE_B=$(find "$HUB/doctrine" -type f -iname "*archive*" 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' ')
EVI_I_B=$(bytes_glob "$HUB/evidence/implementer")
EVI_V_B=$(bytes_glob "$HUB/evidence/verifier")
TODO_LOG_B=$([ -f "$HUB/evidence/worker-runs.log" ] && wc -c < "$HUB/evidence/worker-runs.log" | tr -d ' ' || echo 0)
TODO_LOG_ARCHIVE_B=$([ -f "$HUB/evidence/worker-runs-archive.log" ] && wc -c < "$HUB/evidence/worker-runs-archive.log" | tr -d ' ' || echo 0)
row "haven/diagrams/*archive*" "$ARCHIVE_B"
row "doctrine/**/*archive*" "$DOCTRINE_ARCHIVE_B"
row "evidence/implementer/" "$EVI_I_B"
row "evidence/verifier/" "$EVI_V_B"
row "evidence/worker-runs.log" "$TODO_LOG_B"
row "evidence/worker-runs-archive.log" "$TODO_LOG_ARCHIVE_B"
COLD_B=$(( ARCHIVE_B + DOCTRINE_ARCHIVE_B + EVI_I_B + EVI_V_B + TODO_LOG_B + TODO_LOG_ARCHIVE_B ))
row "= cold storage total" "$COLD_B"
echo
TOTAL_B=$(( SESSION_B + COLD_B ))
echo "-------------------------------------------------------------------"
printf "TOTAL agent-hub/ on disk: %d B  ~%d tok\n" "$TOTAL_B" "$((TOTAL_B/4))"
printf "Recurring per-session cost: %d B  ~%d tok (%.0f%% of total)\n" \
  "$SESSION_B" "$((SESSION_B/4))" "$(echo "$SESSION_B $TOTAL_B" | awk '{print ($1/$2)*100}')"
echo
echo "FLAGS:"
DIAG_FILE="$HUB/haven/diagrams/dev-loop.prime-mermaid.md"
if [ -f "$DIAG_FILE" ]; then
  DB=$(wc -c < "$DIAG_FILE")
  FULL_SEALED=$(grep -cE '\| SEALED \|' "$DIAG_FILE" 2>/dev/null)
  POINTER_SEALED=$(grep -cE '— archived, see' "$DIAG_FILE" 2>/dev/null)
  REAL_SEALED=$(( FULL_SEALED - POINTER_SEALED ))
  check_threshold_bytes "dev-loop.prime-mermaid.md" "$DB" 15360 \
    "$REAL_SEALED full SEALED entries not yet archived, see rows below"
  if [ "$DB" -gt 15360 ]; then
    echo "    Ready-to-move rows (copy each VERBATIM into dev-loop-archive.md's"
    echo "    PM status table, then replace it here with a compact pointer row"
    echo "    '| node | state | date — archived, see dev-loop-archive.md. Evidence: ... |'):"
    grep -E '\| SEALED \|' "$DIAG_FILE" 2>/dev/null | grep -vE '— archived, see' | sed 's/^/      /'
  else
    echo "    ($REAL_SEALED full SEALED entries, $POINTER_SEALED archived pointers)"
  fi
fi
check_threshold "$HUB/doctrine/domains/PROJECT.md" 15360 \
  "consider moving Traps/Decisions rows older than the current work session to doctrine/domains/PROJECT-archive.md"
DOCTRINE_THRESHOLD=51200
check_threshold_bytes "doctrine/ as a whole" "$DOCTRINE_B" "$DOCTRINE_THRESHOLD" \
  "aggregate signal, no single archive destination. Check which file grew: domains/PROJECT.md over 15KB → archive via PROJECT-archive.md (see above); MEMORY.md/SOUL.md/INDEX.md/standards/*.md over 8KB → anomaly, not an archive candidate (see step 4 below)."
check_threshold "$HUB/evidence/worker-runs.log" 15360 \
  "consider moving lines older than the current work session to evidence/worker-runs-archive.log (see evidence/README.md's archiving convention)"
echo
echo "  Static reference files (should stay small by design — no accumulating"
echo "  list to archive; growth here likely means misplaced content, not a"
echo "  normal archive candidate):"
for f in "$HUB/doctrine/MEMORY.md" "$HUB/doctrine/SOUL.md" "$HUB/doctrine/INDEX.md" \
         "$HUB/doctrine/standards/edit-verification.md" "$HUB/doctrine/standards/recipes.md"; do
  check_threshold "$f" 8192 \
    "unexpected growth for a static file — check for a Correction that belongs in the worker's own MEMORY.md, or a Decision that belongs in PROJECT.md, before creating a dedicated archive file for this one"
done
```

2. Report the output verbatim — don't paraphrase the numbers into prose,
   the table is already the report.
3. If a flag fires on `dev-loop.prime-mermaid.md`, `PROJECT.md`, or
   `worker-runs.log`, that's a real signal to do an archive pass (see
   `dev-loop-archive.md` / `PROJECT-archive.md` / `worker-runs-archive.log`'s
   own convention notes, or the equivalent header sections in the active
   files) — but this command itself never edits anything. Archiving is a
   separate, explicit action. [amended 2026-09-02] The diagram flag prints
   the exact rows to move (not just "consider moving nodes") — copy-paste
   is the whole remaining effort, so there's no excuse to defer it past the
   current session the way a vague warning invites.
4. [added 2026-09-05] If a flag fires on one of the 5 static reference
   files (`MEMORY.md`, `SOUL.md`, `INDEX.md`, `standards/*.md`), that's
   NOT an archive signal — those files have no accumulating list and no
   defined archive destination by design. Treat it as an anomaly: read the
   file, find what's misplaced (a Correction that belongs in the worker's
   own `MEMORY.md`, a Decision that belongs in `PROJECT.md`, a recipe that
   belongs in `haven/workers/<wid>/recipes/`), and move it to its one
   correct home instead of inventing a new archive file for a file that
   was never meant to grow.
5. [added 2026-09-13] `doctrine/ as a whole` gets its own flag on top of
   the per-file ones above — `doctrine/` (root files + `domains/` +
   `standards/`, archives excluded) is the single biggest chunk of the
   recurring per-session cost and had no aggregate check before, only
   `PROJECT.md` individually. This flag has no archive file of its own —
   it's a router, not a destination: when it fires, re-read the per-file
   flags above to find which specific file actually grew, then apply
   *that* file's own convention (step 3's archive pass if it's
   `PROJECT.md`, step 4's anomaly triage if it's one of the 5 static
   files). Don't create a `doctrine-archive.md` for this flag — it exists
   to catch the case where several files each stayed under their own
   threshold but the directory's total still crept up.

## If this hub uses epic sharding [added 2026-09-02]
If `haven/diagrams/index.md` exists (opt-in, see
`kit/agent-hub-templates.md` §9️⃣.3), `DIAG_ACTIVE_B` above sums bytes
across **every** `dev-loop-<epic>.prime-mermaid.md`, not just the one(s)
marked `active: true`. Treat "haven/diagrams/ (active file only)" as an
**upper bound** in that case, not the real per-session cost — `/boot` and
`pick_next` only read the active epic file(s) + `index.md`, per
`boot.md` step 5. This script doesn't parse `index.md`'s `active` column
(keeping it a plain byte-counting script, not a markdown-table parser) —
if you need the real per-session number under sharding, sum
`index.md` + only the active epic file(s) by hand.

## What the numbers mean
- **Recurring per-session cost** — what a fresh implementer or verifier
  worker reads before touching any code. This is the number that actually
  compounds: every subagent spawned for a verify pass pays it again, from
  zero, with no cache reuse across separate agent contexts.
- **Cold storage** — `evidence/` and archived rows from the diagram,
  `PROJECT.md`, and `worker-runs.log`. Large here is normal and not itself
  a problem: `/boot` and `pick_next` only touch a handful of the most
  recent evidence notes, not the whole directory. Only worth worrying
  about if something starts reading it in bulk (e.g. a recipe that globs
  all of `evidence/` instead of the specific notes it needs).

## Runtime
`/hub-tokens`. Read-only — no seal gate, no evidence note, no worker
identity needed (this isn't a code-repo change).
