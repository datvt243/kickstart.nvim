# agent-hub — nvim-config

> Entry point for a human reader. The agent itself starts from `CLAUDE.md`.

This is the "one-person development hub" for the personal Neovim config
at the repo root (`~/.config/nvim`, kickstart.nvim-based, terminal +
VSCode). Pure markdown — no code lives here (`CODE_IN_HAVEN` forbids it).

## Layout
- `doctrine/` — verified truth: exact commands (`MEMORY.md`), this
  project's own ground truth (`domains/PROJECT.md`).
- `haven/` — worker memory/convention (implementer, verifier) + the
  single progress diagram (`haven/diagrams/`).
- `evidence/` — append-only audit trail, committed to git, never deleted.

## Daily loop
```
/boot                              # 60s orientation, read-only
/worker implementer "<task>"       # implement, real tests, evidence note
/worker verifier "<task>"          # independent verify → SEAL | REOPEN
/ship "<task>"                     # commit + push, only after SEAL
```
Or combine implement+verify: `/todo "<task>"` / `/todo #<issue-number>`.

See `INDEX.md` for the full file map, `NORTHSTAR.md` for what "done" means.
