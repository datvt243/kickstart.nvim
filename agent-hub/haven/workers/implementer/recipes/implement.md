> This is the recipe that touches code the most — where `EDIT_UNVERIFIED`
> gets caught or slips through.

# Contract
- Input: the output of `pick_next`.
- Output: `{status: sealed_pending_verifier | reopened_by_test | failed, node,
  diff summary, command, evidence}`
- NEVER: `status: done` — only the verifier uses a sealed status.

## Steps
1. Re-read the node + acceptance criteria.
2. Read every related file before writing — match the existing
   naming/style/idiom. For a plugin file, check `doctrine/domains/
   PROJECT.md`'s "Stack + shape" section for the right subfolder
   (`editor/`, `coding/`, `colorscheme/`, `formatting/`, `ui/`,
   `treesitter/`, `tools/`) and the "Plugin setup config" convention
   (`local config = {...}` block, banner comment) from the repo's own
   `CLAUDE.md`.
3. Smallest diff — only change what the acceptance criteria require.
4. SEAL GATE before any outward-facing action — stop, show the diff,
   wait for approval.
5. Run the EXACT test command from `doctrine/MEMORY.md`
   (`./scripts/health.sh`) — copied verbatim.
6. READ THE OUTPUT BACK verbatim — a claim that can't be cited =
   `EDIT_UNVERIFIED`. For a plugin change, also confirm (and record) the
   2-axis check from `doctrine/domains/PROJECT.md` (VSCode vs Terminal,
   Windows vs macOS) where applicable.
7. Only report `sealed_pending_verifier` once ALL criteria pass with
   evidence. If the change touched a keymap, confirm
   `keymaps-terminal.md`/`keymaps-vscode.md` were updated in this same
   diff before reporting.
8–9. If a new bug/trap is found, consider recording it in
   `doctrine/domains/` or `MEMORY.md`.
10. Write to `evidence/` per the format in `evidence/README.md`.
11. ONLY when the result is `blocked` or `failed` (never reaches the
    verifier) — append 1 line to `evidence/worker-runs.log`:
    `role=implementer outcome=blocked|failed node=<slug>
    hub_bytes_before=<N from pick_next step 7> verifier_rerun=n/a`. When
    the result is `sealed_pending_verifier`, do NOT log here — the
    verifier will log both sides (before/after) in
    `recipes/verify_seal.md` once it has a real verdict. This logging
    runs identically whether called via `/todo` or by typing
    `/worker implementer` by hand — independent of how it's invoked.

## Hard rules honored
`SmallestDiff` | `TestsBeforeDone` | `EvidencePerAction` | `NoSilentFailure` |
`NodeBeforeCode`

## Failure branches
| Failure | Handling |
|---|---|
| Missing test command in `doctrine/MEMORY.md` | `blocked`, suggest filling in `<<FILL>>`, log per step 11 |
| A failure from missing setup (env, deps) | Report the REAL error, don't work around it, log per step 11 |
| `nvim` not on `$PATH` (health.sh exits 127) | Report the real error, `blocked` — don't guess a different binary path |

## Runtime
`/worker implementer "<task>"`.
