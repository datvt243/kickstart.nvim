# 2026-09-28 — dashboard-reopen-and-quiet

- Worker: implementer
- Version: 0.1.0
- Node: `dashboard-reopen-and-quiet` (`haven/diagrams/dev-loop.prime-mermaid.md`)
- Task (verbatim, issue #1): "Dashboard: (1) sau khi đóng hết buffer thì tự
  hiện lại dashboard-nvim thay vì màn hình trống; (2) tắt các lint/diagnostic
  hiển thị trên buffer dashboard (giống cách đã ẩn number/cursorline)"

## Hub bytes before: 45479
(root=8039, doctrine=13744, diagram active=2755, implementer bundle=10372,
verifier bundle=10569 — per `/hub-tokens` per-session formula)

## Acceptance criteria clarified: none needed
No existing row to rewrite — this is a fresh node, criteria written
directly (not vague, each maps to a real check):
1. After the last listed buffer is closed (`:bd`), the buffer that ends up
   showing is `filetype=dashboard`, not Neovim's own auto-created empty
   `[No Name]` scratch buffer — verified via a headless script that opens
   a real file, runs `:bd`, then reads back `&filetype`.
2. A buffer with `filetype=dashboard` has diagnostics disabled
   (`vim.diagnostic.is_enabled({bufnr=<buf>})` == false) — verified by
   reading the value back after entering the dashboard buffer.
3. `./scripts/health.sh` still exits 0 (load, `luac -p`, `:checkhealth`).

## Node self-check (3 error classes)
- Ambiguity: none — no vague adjective, each criterion has a concrete
  read-back command.
- Underspecification: none — each criterion has a clear pass/fail value.
- Coverage gap: none — both point at the same file that will change:
  `lua/custom/plugins/dashboard.lua`.

## Root cause found before implementing
`lua/custom/plugins/dashboard.lua` already has a `BufDelete` autocmd
(added in commit 6c90240) meant to reopen `Dashboard` when the listed
buffer count reaches 0. It doesn't fire in the reported case: when the
LAST listed buffer is deleted, Neovim's own window-needs-a-buffer rule
immediately creates a new anonymous scratch buffer in that window, and
that auto-created buffer is `buflisted=true` by default — so by the time
the `vim.schedule` callback counts listed buffers, it counts 1 (the new
scratch buffer), never 0, so `Dashboard` never fires and the user is left
staring at `[No Name]`. Fix: also treat "only 1 listed buffer left, and
it's an unnamed/empty/unmodified scratch buffer" as the same trigger
condition, and replace it with `Dashboard` instead of leaving it.
