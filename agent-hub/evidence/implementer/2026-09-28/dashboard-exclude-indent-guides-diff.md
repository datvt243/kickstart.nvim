# 2026-09-28 — dashboard-exclude-indent-guides — DIFF

- Worker: implementer
- Version: 0.1.0
- Node: `dashboard-exclude-indent-guides`

## Diff
| File | Why |
|---|---|
| `lua/custom/plugins/editor/indent_line.lua` | Added an explicit `local config` (banner-comment convention from repo `CLAUDE.md`) passed to `require('ibl').setup(config)`, with `exclude.filetypes` listing ibl's own defaults (`lspinfo`, `packer`, `checkhealth`, `help`, `man`, `gitcommit`, `TelescopePrompt`, `TelescopeResults`, `''`) plus `dashboard`. Comment records why the full default list is repeated rather than just `{'dashboard'}`: ibl merges config with `vim.tbl_deep_extend('keep', input, base)` (confirmed by reading the installed plugin's `lua/ibl/config.lua:247`), which merges arrays by numeric index — passing only `{'dashboard'}` would silently overwrite index 1 (`'lspinfo'`) of the default list instead of appending, dropping that exclusion. |

## Command
`./scripts/health.sh`

## Output
```
[1/3] load config...
  ✓ OK
[2/3] parse .lua...
  ✓ OK (49 files)
[3/3] checkhealth...
  → 0 ERROR, 44 WARNING

DONE ✓ — không có lỗi
```
44 WARNING matches the pre-existing baseline recorded in
`evidence/verifier/2026-09-28/dashboard-reopen-and-quiet-seal.md` — not a
new warning introduced by this change (spot-checked: the new-diagnostics
list surfaced in-session for this edit is only the generic
"Undefined global `vim`" lua_ls warning already present identically on
every other plugin file in the repo, e.g. `init.lua`, `dashboard.lua`,
`autopairs.lua` — unrelated to this change).

## Functional check (headless, ibl exclusion)
Command:
```
nvim --headless -c "Dashboard" -c "lua vim.schedule(function()
  local cfg = require('ibl.config').get_config(vim.api.nvim_get_current_buf())
  local utils = require('ibl.utils')
  local active = utils.is_buffer_active(vim.api.nvim_get_current_buf(), cfg)
  vim.fn.writefile({'FT='..vim.bo.filetype, 'IBL_ACTIVE='..tostring(active)}, '/tmp/ibl_check.txt')
  vim.cmd('qa!')
end)"
```
Output (`/tmp/ibl_check.txt`) on the dashboard buffer:
```
FT=dashboard
IBL_ACTIVE=false
```
Same check opening a normal file (`nvim --headless init.lua ...`),
output (`/tmp/ibl_check2.txt`):
```
FT=lua
IBL_ACTIVE=true
```

## Acceptance
| # | Criterion | Evidence | Verdict |
|---|---|---|---|
| 1 | `./scripts/health.sh` exits 0 clean | Output block above: `[1/3] ✓ OK`, `[2/3] ✓ OK (49 files)`, `[3/3] → 0 ERROR, 44 WARNING`, `DONE ✓` | met |
| 2 | ibl reports the dashboard buffer as excluded (no indent guide lines) | `/tmp/ibl_check.txt`: `FT=dashboard`, `IBL_ACTIVE=false` | met |
| 3 | ibl still active on a normal filetype (no regression) | `/tmp/ibl_check2.txt`: `FT=lua`, `IBL_ACTIVE=true` | met |

## 2-axis check (`doctrine/domains/PROJECT.md`)
- VSCode vs Terminal: `indent_line.lua` is already guarded
  (`if vim.g.vscode ~= nil then return end`, line 3, unchanged by this
  diff) — terminal-only, VSCode session unaffected.
- Windows vs macOS: change is a pure Lua string-list literal
  (filetype names) inside a plugin `setup()` call — no path separators,
  no hardcoded Unix paths, no OS-only external tool, no `.cmd`/`.bat`
  spawn. Static-analysis clean on both OSes; no OS-specific behavior
  introduced, so no separate Windows end-to-end run needed for this
  class of change.

## Keymap doc sync
N/A — no keymap added/changed by this diff.

## Noticed, not done
- The other pre-existing 44 warnings from `:checkhealth` (generic
  `Undefined global vim` lua_ls warnings across ~20 plugin files) are
  out of scope for this task — not touched.

## Seal gate
None — no commit/push/publish happened in this pass (local file edits
only, evidence notes + diagram update inside `agent-hub/`).
