# 2026-10-03 — claudecode-reset-on-project-switch — verdict: SEAL

- Worker: verifier
- Node: `claudecode-reset-on-project-switch`
- Issue: #3
- Evidence audited: `evidence/implementer/2026-10-03/claudecode-reset-on-project-switch-diff.md`
  and its companion `-plan.md`

## Isolation proof
This pass runs as the `verifier` subagent spawned via the Agent tool
with task string `run \`/worker verifier
agent-hub/evidence/implementer/2026-10-03/claudecode-reset-on-project-switch-diff.md\``
— a blank-context spawn distinct from the implementer pass that produced
the diff (which worked from a `/todo`-style task string describing issue
#3, not this evidence-note path). I have no memory of the implementer's
reasoning session; everything below was re-derived from disk in this
spawn.

## Verdict
**SEAL**

## Re-run
`partial` — re-ran `./scripts/health.sh` fully myself from repo root
(per explicit instruction for this verify pass) and `stylua --check`
on the changed file; did NOT re-execute the implementer's headless
functional-check Lua scripts (`/tmp/test_claudecode_dirchanged.lua`,
`/tmp/test_claudecode_dirchanged_neg.lua`) — audited their cited output
instead. Reason this falls under audit-only for the functional scripts:
per `recipes/verify_seal.md`'s "Re-run scope", this diff is not a
plugin install nor an `init.lua` structural change (it edits an
already-installed plugin's config file, same risk class as an ordinary
keymap tweak), the note's output is verbatim/not truncated, and the
command matches `doctrine/MEMORY.md` — none of the re-run trigger
conditions apply to the Lua scripts. Confirmed the two script files
still exist on disk (`ls /tmp/test_claudecode_dirchanged*.lua` →
both present) as a cheap authenticity check before relying on their
cited output.

## What I checked, with citations

1. **Command matches doctrine** — `doctrine/MEMORY.md` row: `Test
   (headless healthcheck)` = `./scripts/health.sh` run from repo root.
   Note cites exactly this command. Match.

2. **Output not cut/hidden, and independently reproduced** — I ran
   `./scripts/health.sh` myself from `/Users/_david/.config/nvim` this
   pass. My own output:
   ```
   [1/3] load config...  ✓ OK
   [2/3] parse .lua...  ✓ OK (49 files)
   [3/3] checkhealth...  → 0 ERROR, 44 WARNING
   DONE ✓ — không có lỗi
   ```
   Identical to the note's quoted output, and identical to the prior
   sealed baseline (44 WARNING, 0 ERROR,
   `evidence/verifier/2026-09-28/dashboard-exclude-indent-guides-seal.md`).
   No new warning/error. Acceptance criterion 1 (plan note) met.

3. **Diff matches what the note claims** — ran `git diff --
   lua/custom/plugins/tools/claudecode.lua` myself; the actual working
   tree diff is exactly the 1 autocmd block quoted in the evidence note
   (`DirChanged`, augroup `claudecode-close-on-project-switch`, `global`
   scope guard, `initialized` guard, `get_active_terminal_bufnr()` +
   `nvim_buf_delete(bufnr, { force = true })`). No extra, no missing
   lines beyond that block. (Minor note: the evidence note's diff
   section header says "18 lines" where my own count of the `+` lines
   in `git diff` is 15 — a cosmetic miscount in the note's prose, not a
   misrepresentation of the actual diff content, which matches
   verbatim. Not grounds for REOPEN.)

4. **Functional claim (criterion 2)** — audited, not re-executed (see
   "Re-run" above). Note cites concrete pid-liveness evidence
   (`pid=1313`, `buf_valid_before=true` → `buf_valid_after=false`, then
   `DEAD (job killed, correct)` vs the labeled bug case `STILL ALIVE
   (BUG)` which it reports did NOT happen) for the positive case, and a
   negative case showing the `event.match ~= 'global'`/`initialized`
   guards hold with no deletion, followed by the positive path firing
   correctly right after on the same autocmd instance. This is real
   simulation output, not reasoning-only. Confirmed the referenced
   script files exist on disk.

5. **2-axis check (criterion 3, `doctrine/domains/PROJECT.md` +
   `CLAUDE.md`)**:
   - VSCode vs Terminal: I read
     `lua/custom/plugins/tools/claudecode.lua` line 4 myself —
     `if vim.g.vscode ~= nil then return end` — pre-existing, unchanged,
     confirmed present. The new autocmd is appended after the existing
     keymaps inside this same guarded file, so it inherits the
     terminal-only guard. Matches the note's claim.
   - Windows vs macOS: diff uses only `nvim_create_autocmd`,
     `nvim_create_augroup`, `nvim_buf_delete`, `require` — no path
     separators, no `~`/`/tmp` literals, no OS-only external tool, no
     `.cmd`/`.bat` spawn. Confirmed by my own read of the diff. No
     Windows machine available this session — note explicitly says
     end-to-end Windows verification is pending, which is the exact
     allowance `CLAUDE.md`'s working rules give ("If a machine of the
     other OS isn't available, verify by static analysis + simulation
     and note that end-to-end testing on the other OS is still
     pending"). Criterion met as stated, not overclaimed.

6. **Keymap doc sync (criterion 4)** — confirmed via `git diff`: no
   `vim.keymap.set` added or changed in this diff, only a new
   `DirChanged` autocmd. `keymaps-terminal.md`/`keymaps-vscode.md`
   update correctly not required. N/A claim holds.

7. **Formatting** — ran
   `~/.local/share/nvim/mason/bin/stylua --check
   lua/custom/plugins/tools/claudecode.lua` myself → exit 0. Matches
   the note's claim.

8. **Trap recorded** — confirmed row present in
   `doctrine/domains/PROJECT.md`'s Traps table: "`claudecode.nvim`'s
   `terminal.close()` doesn't kill the job" — read it directly, it is
   there with the fix description matching the diff.

9. **Seal gate** — correctly not invoked: no commit/push/publish in
   this pass, just local file state + a prior uncommitted diff being
   reviewed. Consistent with `agent-hub/CLAUDE.md`'s Seal gate (only
   outward-facing actions require it) and this repo's stricter
   "never push unasked" rule in `doctrine/domains/PROJECT.md`.

10. **Proportionality (`SmallestDiff`)** — diff adds exactly one
    autocmd block, nothing else touched, no refactor. Proportionate to
    the node.

## Forbidden states scan
- `ADHOC_WORK` — no. Node `claudecode-reset-on-project-switch` exists
  on `haven/diagrams/dev-loop.prime-mermaid.md` (was IN_PROGRESS before
  this verdict), issue #3 traced.
- `NO_EVIDENCE` — no. Evidence note + plan note both present under
  `evidence/implementer/2026-10-03/`.
- `EDIT_UNVERIFIED` — no. `./scripts/health.sh` was run and its output
  read back verbatim, both by the implementer pass and independently
  by me this pass.
- `CODE_IN_HAVEN` — no. Only `lua/custom/plugins/tools/claudecode.lua`
  (a real code-repo file) was touched; nothing under `haven/` carries
  code.
- `DIAGRAM_DRIFT` — no, once this verdict updates PM status (done below)
  to match the sealed code state.

## PM status
Updated `agent-hub/haven/diagrams/dev-loop.prime-mermaid.md`,
`claudecode-reset-on-project-switch` row: `IN_PROGRESS` → `SEALED`
(forward-only ratchet, `LAI-13`). Notes column now points at this file.

## Hub bytes
- Before (reused from implementer's plan note, not re-measured):
  43177
- After (measured by me this pass, post PM-status update, using
  `/hub-tokens`'s exact per-session-total formula): root=7923
  doctrine=15144 diag=3137 impl=10372 verif=10569 → **47145**
