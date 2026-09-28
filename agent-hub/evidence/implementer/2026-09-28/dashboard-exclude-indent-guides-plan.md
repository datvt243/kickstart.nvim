# 2026-09-28 — dashboard-exclude-indent-guides — PLAN

- Worker: implementer
- Version: 0.1.0
- Node: `dashboard-exclude-indent-guides` (`haven/diagrams/dev-loop.prime-mermaid.md`, new node, state IN_PROGRESS)
- Task (verbatim): "Dashboard buffer (filetype=dashboard) đang bị
  indent-blankline (ibl) vẽ đè indent guide lines lên ASCII
  art/shortcut, do lua/custom/plugins/editor/indent_line.lua chưa loại
  trừ filetype dashboard khỏi ibl. Thêm exclude.filetypes = {
  'dashboard' } (giữ nguyên các default exclude khác nếu cần) vào config
  của ibl.setup(), đảm bảo dashboard sạch line, không đụng các filetype
  khác."

## Hub bytes before: 45485

## No PENDING node matched
Neither of the 2 existing nodes on `dev-loop.prime-mermaid.md`
(`bootstrap-agent-hub`, `dashboard-reopen-and-quiet`) is PENDING — both
SEALED. This is new user-reported work (reported directly in
conversation, not via `/todo`/GitHub issue), so per LAI-13 ("any
regression/new work is a new node, never edit an old SEAL") a new node
`dashboard-exclude-indent-guides` was added to the PM status table as
`IN_PROGRESS`.

## Acceptance criteria
1. `./scripts/health.sh` exits 0 clean (0 ERROR).
2. In a headless Neovim session, opening the dashboard buffer
   (`:Dashboard`) and calling `require('ibl.utils').is_buffer_active(bufnr,
   require('ibl.config').get_config(bufnr))` on that buffer returns
   `false` (ibl treats the buffer as excluded → no indent guide lines
   drawn on it).
3. The same check on a normal buffer (e.g. `init.lua`, filetype `lua`)
   still returns `true` — no regression to indent guides elsewhere.

## Code anchor
`lua/custom/plugins/editor/indent_line.lua` — currently
`require('ibl').setup {}` (empty config, all defaults, `exclude.filetypes`
does not include `dashboard`).

## No `<<FILL>>` blockers
`doctrine/MEMORY.md`'s exact test command is filled in
(`./scripts/health.sh`); nothing to declare here.
