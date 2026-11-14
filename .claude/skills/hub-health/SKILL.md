---
name: hub-health
description: "Health check of agent-hub/: size (read every session vs cold storage, archive flags), real billed tokens per main session / verifier / analyst from Claude Code transcripts, spawn cost, and token waste (re-reads, failing-command loops, oversized tool output). Use when the user asks about hub size, token cost or token waste. Usage: /hub-health [days] [--report agent-hub-init-path]. Read-only on this project; --report writes one report file into agent-hub-init's improvements/report/."
---

# /hub-health — agent-hub health and token cost

Read-only on this project. No file changes here, no seal gate needed —
`--report` only writes into the agent-hub-init repo (step 6).

## Why this exists
`haven/diagrams/dev-loop.prime-mermaid.md` and `doctrine/domains/
PROJECT.md` are both read in full by every worker session (implementer,
verifier, and every subagent spawned for a `/todo` verify pass re-loads
them from scratch). Left unchecked either grows forever and becomes the
single biggest recurring token cost in the hub — this is what the
`dev-loop-archive.md` / `PROJECT-archive.md` conventions (see each file's
own header note) exist to bound. This skill measures whether that's
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
bytes_glob_exclude() { find "$1" -type f \( -name "*.md" -o -name "*.yaml" -o -name "*.yml" \) ! -iname "*archive*" ! -path "*/doctrine/features/*" 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' '; }
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
ANALYST_B=$(bytes_glob "$HUB/haven/workers/analyst")
row "root files (NORTHSTAR/CLAUDE/etc)" "$ROOT_B"
row "doctrine/ (minus features/)" "$DOCTRINE_B"
row "haven/diagrams/ (active file only)" "$DIAG_ACTIVE_B"
row "haven/workers/implementer/" "$IMPL_B"
row "haven/workers/verifier/" "$VERIF_B"
row "haven/workers/analyst/" "$ANALYST_B"
SESSION_B=$(( ROOT_B + DOCTRINE_B + DIAG_ACTIVE_B + IMPL_B + VERIF_B + ANALYST_B ))
row "= per-session total (any worker boot load)" "$SESSION_B"
echo
echo "COLD STORAGE (opened on demand only, NOT re-read wholesale by"
echo "pick_next/verify_seal — large size here is not a recurring cost):"
ARCHIVE_B=$(find "$HUB/haven/diagrams" -type f -iname "*archive*" 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' ')
DOCTRINE_ARCHIVE_B=$(find "$HUB/doctrine" -type f -iname "*archive*" 2>/dev/null -exec cat {} + 2>/dev/null | wc -c | tr -d ' ')
EVI_I_B=$(bytes_glob "$HUB/evidence/implementer")
EVI_V_B=$(bytes_glob "$HUB/evidence/verifier")
EVI_A_B=$(bytes_glob "$HUB/evidence/analyst")
FEATURES_B=$(bytes_glob "$HUB/doctrine/features")
TODO_LOG_B=$([ -f "$HUB/evidence/worker-runs.log" ] && wc -c < "$HUB/evidence/worker-runs.log" | tr -d ' ' || echo 0)
TODO_LOG_ARCHIVE_B=$([ -f "$HUB/evidence/worker-runs-archive.log" ] && wc -c < "$HUB/evidence/worker-runs-archive.log" | tr -d ' ' || echo 0)
row "haven/diagrams/*archive*" "$ARCHIVE_B"
row "doctrine/**/*archive*" "$DOCTRINE_ARCHIVE_B"
row "evidence/implementer/" "$EVI_I_B"
row "evidence/verifier/" "$EVI_V_B"
row "evidence/analyst/" "$EVI_A_B"
row "doctrine/features/ (1 doc per task)" "$FEATURES_B"
row "evidence/worker-runs.log" "$TODO_LOG_B"
row "evidence/worker-runs-archive.log" "$TODO_LOG_ARCHIVE_B"
COLD_B=$(( ARCHIVE_B + DOCTRINE_ARCHIVE_B + EVI_I_B + EVI_V_B + EVI_A_B + FEATURES_B + TODO_LOG_B + TODO_LOG_ARCHIVE_B ))
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
    "$REAL_SEALED full SEALED entries not yet archived ($POINTER_SEALED pointers; verify_seal step 11 should keep these at 0 full / <=20 pointers — a backlog here predates that rule or means step 11 was skipped), see rows below"
  if [ "$DB" -gt 15360 ]; then
    echo "    Ready-to-move rows (copy each VERBATIM into dev-loop-archive.md's"
    echo "    PM status table, then replace it here with a compact pointer row"
    echo "    '| node | state | date — archived, see dev-loop-archive.md. Evidence: ... |'):"
    grep -E '\| SEALED \|' "$DIAG_FILE" 2>/dev/null | grep -vE '— archived, see' | sed 's/^/      /'
  else
    echo "    ($REAL_SEALED full SEALED entries, $POINTER_SEALED archived pointers)"
    [ "$REAL_SEALED" -gt 0 ] && echo "  ⚠ dev-loop.prime-mermaid.md: $REAL_SEALED full SEALED rows not archived — verify_seal step 11 was skipped; collapse them by hand"
  fi
  [ "$POINTER_SEALED" -gt 20 ] && echo "  ⚠ dev-loop.prime-mermaid.md: $POINTER_SEALED pointer rows (cap 20, verify_seal 11c) — delete the oldest lines"
  # a blank/text line after the PM header followed by more rows = rows fell outside the markdown table
  STRAY=$(awk '/^\| Node \| State/{t=1;next} t&&/^\|/{if(gap)n++;next} t{gap=1} END{print n+0}' "$DIAG_FILE")
  [ "$STRAY" -gt 0 ] && echo "  ⚠ dev-loop.prime-mermaid.md: $STRAY rows sit after a blank/text line, outside the PM table — move them back under the header, drop the blank lines, keep the table as the file's last block"
fi
check_threshold "$HUB/doctrine/domains/PROJECT.md" 15360 \
  "consider moving Traps/Decisions rows older than the current work session to doctrine/domains/PROJECT-archive.md"
DOCTRINE_THRESHOLD=51200
check_threshold_bytes "doctrine/ as a whole" "$DOCTRINE_B" "$DOCTRINE_THRESHOLD" \
  "aggregate signal, no single archive destination. Check which file grew: domains/PROJECT.md over 15KB → archive via PROJECT-archive.md (see above); MEMORY.md/SOUL.md/INDEX.md over 8KB or standards/*.md over 12KB → anomaly, not an archive candidate (see step 4 below)."
check_threshold "$HUB/evidence/worker-runs.log" 15360 \
  "consider moving lines older than the current work session to evidence/worker-runs-archive.log (see evidence/README.md's archiving convention)"
echo
echo "VERIFIER SPAWNS (worker-runs.log; no spawn= field = fresh, pre-2026-11-07):"
cat "$HUB/evidence/worker-runs-archive.log" "$HUB/evidence/worker-runs.log" 2>/dev/null | awk '
  /role=verifier/ { v++; if (/outcome=REOPEN/) r++; if (/spawn=resumed/) s++; if (/rerun=(partial|full)/) x++ }
  /role=implementer/ && /outcome=(blocked|failed)/ { f++ }
  END { if (!v) { print "  (no verifier lines)"; exit }
        printf "  verdicts %d | REOPEN %d (%.0f%%) | spawns fresh %d, resumed %d | re-ran commands %d (%.0f%%) | implementer blocked/failed %d\n", v, r, 100*r/v, v-s, s, x, 100*x/v, f }'
echo
echo "  Static reference files (should stay small by design — no accumulating"
echo "  list to archive; growth here likely means misplaced content, not a"
echo "  normal archive candidate):"
for f in "$HUB/doctrine/MEMORY.md" "$HUB/doctrine/SOUL.md" "$HUB/doctrine/INDEX.md"; do
  check_threshold "$f" 8192 \
    "unexpected growth for a static file — check for a Correction that belongs in the worker's own MEMORY.md, or a Decision that belongs in PROJECT.md, before creating a dedicated archive file for this one"
done
# standards/*.md get 12KB: a project-specific standard grows with its feature (2026-10-24)
for f in "$HUB/doctrine/standards/"*.md; do
  check_threshold "$f" 12288 \
    "unexpected growth for a static file — check for a Correction that belongs in the worker's own MEMORY.md, or a Decision that belongs in PROJECT.md, before creating a dedicated archive file for this one"
done
```

1b. Transcripts (default window 30 days; `[days]` overrides). Reads
   Claude Code's own transcripts for this repo
   (`~/.claude/projects/<repo path, non-alphanumerics → ->/*.jsonl` plus
   each session's `subagents/*.jsonl`), so the numbers are what was
   actually billed — cache reads included, not `bytes / 4`. A subagent
   counts as verifier/analyst when its spawn description names that
   role. The transcript format is Claude Code's internal one, not a
   public API — a parse that finds nothing prints "(no …)" instead of
   guessing.

```bash
ROOT="${ROOT:-.}"
DAYS="${DAYS:-30}"   # set to the [days] argument when given
TDIR="$HOME/.claude/projects/$(cd "$ROOT" && pwd -P | sed 's|[^A-Za-z0-9]|-|g')"
python3 - "$TDIR" "$DAYS" <<'PY'
import json, os, sys, time, glob
tdir, days = sys.argv[1], int(sys.argv[2])
if not os.path.isdir(tdir):
    sys.exit(f"  (no transcripts at {tdir})")
cut = time.time() - days * 86400

def scan(path):
    seen, uses, results = {}, {}, {}
    for line in open(path, errors="ignore"):
        try:
            m = json.loads(line).get("message") or {}
        except ValueError:
            continue
        if m.get("usage") and m.get("id"):
            seen[m["id"]] = m["usage"]  # one API call spans several lines with the same id
        if isinstance(m.get("content"), list):
            for b in m["content"]:
                if not isinstance(b, dict):
                    continue
                if b.get("type") == "tool_use":
                    uses[b["id"]] = (b.get("name"), b.get("input") or {})
                elif b.get("type") == "tool_result":
                    c = b.get("content")
                    # text only: an image block's base64 length says nothing about its token cost
                    size = len(c) if isinstance(c, str) else sum(len(x.get("text", "")) for x in c or [] if isinstance(x, dict))
                    results[b.get("tool_use_id")] = (size, bool(b.get("is_error")))
    t = {"fresh": 0, "cache_write": 0, "cache_read": 0, "out": 0}
    for u in seen.values():
        t["fresh"] += u.get("input_tokens", 0)
        t["cache_write"] += u.get("cache_creation_input_tokens", 0)
        t["cache_read"] += u.get("cache_read_input_tokens", 0)
        t["out"] += u.get("output_tokens", 0)
    return t, len(seen), uses, results

def role(meta):
    d = (meta.get("description", "") + " " + meta.get("agentType", "")).lower()
    return "verifier" if "verif" in d else "analyst" if "analy" in d else "other subagent"

groups, dup, loops, big = {}, {}, {}, []
def add(key, path):
    t, n, uses, results = scan(path)
    g = groups.setdefault(key, {"runs": 0, "calls": 0, "fresh": 0, "cache_write": 0, "cache_read": 0, "out": 0})
    g["runs"] += 1; g["calls"] += n
    for k in t: g[k] += t[k]
    reads, fails = {}, {}
    for uid, (name, inp) in uses.items():
        size, err = results.get(uid, (0, False))
        if name == "Read":
            k = (inp.get("file_path"), inp.get("offset"), inp.get("limit"))
            reads.setdefault(k, []).append(size)
        if name == "Bash" and err:
            k = " ".join(str(inp.get("command", "")).split())[:120]
            fails[k] = fails.get(k, 0) + 1
        if size > 40000:
            big.append((size, key, name, str(inp.get("file_path") or inp.get("command") or inp.get("description") or "")[:90]))
    for (fp, _, _), sizes in reads.items():
        if len(sizes) > 1:
            d = dup.setdefault(fp, [0, 0])
            d[0] += len(sizes) - 1; d[1] += sum(sizes[1:])
    for cmd, n in fails.items():
        if n >= 3:
            loops[cmd] = max(loops.get(cmd, 0), n)

for f in glob.glob(os.path.join(tdir, "*.jsonl")):
    if os.path.getmtime(f) < cut:
        continue
    add("main session", f)
    for s in glob.glob(os.path.join(f[:-6], "subagents", "*.jsonl")):
        try:
            meta = json.load(open(s[:-6] + ".meta.json"))
        except (OSError, ValueError):
            meta = {}
        add(role(meta), s)
if not groups:
    sys.exit(f"  (no sessions in the last {days} days)")

print(f"BILLED TOKENS (transcripts, last {days} days):")
print(f"  {'':16}{'runs':>5}{'calls':>7}{'fresh in':>10}{'cache write':>13}{'cache read':>12}{'output':>9}{'in/run':>10}{'write/run':>11}")
for k in ("main session", "verifier", "analyst", "other subagent"):
    g = groups.get(k)
    if g:
        tin = g["fresh"] + g["cache_write"] + g["cache_read"]
        print(f"  {k:16}{g['runs']:>5}{g['calls']:>7}{g['fresh']:>10}{g['cache_write']:>13}{g['cache_read']:>12}{g['out']:>9}{tin // g['runs']:>10}{g['cache_write'] // g['runs']:>11}")
print()
print("TOKEN WASTE (transcripts, ~tok = chars / 4):")
top = sorted(dup.items(), key=lambda x: -x[1][1])[:8]
print(f"  re-reads (same file + range, same run): {sum(v[0] for v in dup.values())} extra, ~{sum(v[1] for v in dup.values()) // 4} tok")
for fp, (n, ch) in top:
    print(f"    {n:>4}x  {'image' if not ch else f'~{ch // 4} tok':>12}  {fp}")
print(f"  failing Bash command repeated >=3x in one run: {len(loops)}")
for cmd, n in sorted(loops.items(), key=lambda x: -x[1])[:5]:
    print(f"    {n:>4}x  {cmd}")
print(f"  tool results >40k chars (~10k tok): {len(big)}")
for size, who, name, what in sorted(big, reverse=True)[:5]:
    print(f"    ~{size // 4:>7} tok  {who:15} {name}: {what}")
PY
```

2. Report the output verbatim — don't paraphrase the numbers into prose,
   the table is already the report.
3. If a flag fires on `dev-loop.prime-mermaid.md`, `PROJECT.md`, or
   `worker-runs.log`, that's a real signal to do an archive pass (see
   `dev-loop-archive.md` / `PROJECT-archive.md` / `worker-runs-archive.log`'s
   own convention notes, or the equivalent header sections in the active
   files) — but this skill itself never edits anything. Archiving is a
   separate, explicit action. [amended 2026-09-02] The diagram flag prints
   the exact rows to move (not just "consider moving nodes") — copy-paste
   is the whole remaining effort, so there's no excuse to defer it past the
   current session the way a vague warning invites. [amended 2026-10-24]
   That alone did not hold (3 production hubs at 89-175KB) — the real fix
   is `verify_seal` step 11 collapsing each row at SEAL time. A diagram
   flag now means a pre-rule backlog (one-time pass) or a verifier that
   skipped step 11 (check the latest verdict notes).
4. If a flag fires on one of the 5 static reference
   files (`MEMORY.md`, `SOUL.md`, `INDEX.md`, `standards/*.md`), that's
   NOT an archive signal — those files have no accumulating list and no
   defined archive destination by design. Treat it as an anomaly: read the
   file, find what's misplaced (a Correction that belongs in the worker's
   own `MEMORY.md`, a Decision that belongs in `PROJECT.md`, a recipe that
   belongs in `haven/workers/<wid>/recipes/`), and move it to its one
   correct home instead of inventing a new archive file for a file that
   was never meant to grow. [amended 2026-10-24] `standards/*.md` use a
   12KB threshold, not 8KB — a project-specific standard (e.g. a PDF-export
   spec) legitimately grows with the feature it encodes.
5. `doctrine/ as a whole` gets its own flag on top of
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
5b. Spawn cost and token waste (step 1b) — each is a lead, not a verdict;
   read the run before blaming the hub:
   - REOPEN over ~20% → implementers hand off notes with gaps the
     `implement` step 10b checklist should catch; read the latest
     `reopen.md` notes for the repeating gap.
   - Verifier `re-ran commands` over ~20% → verifiers skip "Re-run
     scope" in `verify_seal.md` (default is audit-only).
   - Verifier `write/run` well above the per-session hub bytes / 4 →
     the verifier loads files outside its manifest `reads:`.
   - A re-read of a file under `agent-hub/` → a GUARD (`boot` step 2,
     `pick_next`, `verify_seal` step 3) was skipped. Re-reads of images
     or files edited in between are usually legitimate.
   - A failing command repeated ≥3x → the `implement` step 6b loop guard
     didn't fire, or the loop ran outside a worker pass.
   - Tool results >40k chars → a command dumped whole logs/files; cap it
     (`| tail`, `head`, `Read` with `limit`) in the recipe that ran it.
6. `--report <agent-hub-init path>`: write the step 1/1b output plus
   the step 3-5b findings into
   `<path>/improvements/report/<YYYY-MM-DD>-#<NN>-hub-health-<project>.md`
   — `<NN>` and the filename follow that repo's
   `.claude/rules/improvements-naming.md` (read it first; next number
   = highest `#` among `report/` filenames + 1, 2 digits). Sections:
   `- **Recorded:**`, `- **Context:**` (project, kit version from
   `agent-hub/.kit-version`, window), `- **Status:** unverified`,
   `## Baseline` (output verbatim), `## Findings` (numbered: what,
   evidence line from the output, suggested kit change — only for
   flags that fired), `## Not checked`. No path given → ask for it, don't
   guess. Never write anything into this project's own files.

## If this hub uses epic sharding
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
- **Cold storage** — `evidence/`, `doctrine/features/` (1 doc opened
  per task via its INDEX), and archived rows from the diagram,
  `PROJECT.md`, and `worker-runs.log`. Large here is normal and not itself
  a problem: `/boot` and `pick_next` only touch a handful of the most
  recent evidence notes, not the whole directory. Only worth worrying
  about if something starts reading it in bulk (e.g. a recipe that globs
  all of `evidence/` instead of the specific notes it needs).

- **Billed tokens** — `write/run` is the cold load each
  spawn pays (the bundle + doctrine read from zero); `in/run` is the
  whole run, cache re-reads included, so it grows with every tool call
  the run makes. A verifier's `write/run` rising over time = the hub
  files it loads grew; `in/run` rising with flat `write/run` = it makes
  more calls per verdict (re-running commands, reading beyond the note).

## Runtime
`/hub-health [days] [--report <agent-hub-init path>]`. Read-only on this
project — no seal gate, no evidence note, no worker identity needed (this
isn't a code-repo change). `--report` writes only into agent-hub-init.
