---
title: nvim-config Northstar
date: 2026-09-20
status: active
authority: 65537
dna: nvim_config
---

> The Northstar is what does NOT change while everything else does.

## One sentence
Keep this personal Neovim config (kickstart.nvim-based, terminal + VSCode)
changeable with confidence — every plugin/keymap change traceable, run
through the real headless healthcheck, never silently breaking either
runtime environment or OS.

## What done means
A node is ONLY considered done when **ALL** (not just any one) of the
following are true:

1. Traces back to exactly one node on `haven/diagrams/`.
2. Has the smallest diff that satisfies that node (no extra refactoring).
3. Ran the project's real test command (from `doctrine/MEMORY.md`) and
   READ THE OUTPUT BACK — not reasoned about.
4. Has an evidence note at `evidence/<...>/<date>-<slug>.md`.
5. The verifier returned `SEAL` with specific cited evidence.
6. The diagram's PM status table has been updated to match.

Missing (3) or (5) → forbidden state `EDIT_UNVERIFIED`.

## What this hub does NOT do
- Touch `init.lua`/`lua/` without a worker + a matching node on the
  diagram (`ADHOC_WORK`)
- Claim a plugin/keymap change works without running
  `./scripts/health.sh` and reading the output back (`EDIT_UNVERIFIED`)
- Leave a real action unrecorded in `evidence/` (`NO_EVIDENCE`)
- Put Lua config code inside `haven/` (`CODE_IN_HAVEN`)
- Change code without updating the diagram's PM status to match
  (`DIAGRAM_DRIFT`)

## The success picture (3 months out)
- 0 forbidden states triggered across the last 20 changes.
- Every new/changed plugin verified clean on both axes from
  `CLAUDE.md`'s working rules (VSCode vs Terminal, Windows vs macOS)
  before SEAL.
- `keymaps-terminal.md`/`keymaps-vscode.md` never drift out of sync with
  the real `vim.keymap.set` calls (spot-checked at SEAL).
- `./scripts/health.sh` run + its output read back for every implementer
  pass — 0 `EDIT_UNVERIFIED` incidents.
- `haven/diagrams/dev-loop.prime-mermaid.md` stays under ~15KB via
  regular archiving; `/hub-tokens` reports no flags.

## Cross-references
`CLAUDE.md` · `doctrine/MEMORY.md` · `haven/diagrams/dev-loop.prime-mermaid.md`
