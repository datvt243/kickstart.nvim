> If any other document contradicts this file about a path or a command,
> THIS FILE WINS. One home per fact — a command living in two files will
> eventually be wrong in one of them.

## What this is
- Hub path (absolute): `/Users/_david/.config/nvim/agent-hub`
- Code repo path (absolute): `/Users/_david/.config/nvim`
- Hub ↔ repo relationship: only touches the repo through a worker, with a
  real test run and an evidence note — never ad-hoc.

## The exact commands
> COPY these — never type them from memory. A command remembered by
> heart drifts, and a drifted command proves the wrong thing.

| Purpose | Command | Run from |
|---|---|---|
| Test (headless healthcheck) | `./scripts/health.sh` | repo root (`/Users/_david/.config/nvim`) |
| Test one file | N/A — `health.sh` checks the whole config in 3 steps (load, `luac -p` parse, `:checkhealth`); no narrower per-file check exists | — |
| Build | N/A — pure Lua config, no build step | — |
| Lint/format | `~/.local/share/nvim/mason/bin/stylua init.lua lua/**/*.lua` | repo root |
| Run locally | `nvim` | repo root |

Windows note (from `scripts/health.sh`'s own header): the script is bash
(macOS/Linux/WSL/git-bash). On pure Windows (cmd/powershell), the
equivalent headless command is:
`nvim --headless "+checkhealth" "+w health.txt" +qa`

## Stack
| Thing | Value |
|---|---|
| Language/runtime | Lua, Neovim 0.11+ |
| Package manager | `vim.pack` (Neovim's built-in plugin manager — NOT lazy.nvim) |
| Test runner | `scripts/health.sh` (headless Neovim healthcheck: load, parse, `:checkhealth`) |

## The default way to work
`/boot` → `/worker implementer "<task>"` → `/worker verifier "<task>"`. Never
skip step 1 in a cold session, never skip step 3.

## Workers
| wid | Role | Actions | Seal actions |
|---|---|---|---|
| implementer | Implementer | pick_next, implement | — |
| verifier | Verifier | verify_seal | SEAL, REOPEN |

## Forbidden states
5 states — see `CLAUDE.md` for detail. These states OVERRIDE every other
skill text.

## Facts that are always true
- No LLM API key exists anywhere in the hub — Claude Code IS the runtime.
- `haven/` is memory, not code.
- `evidence/` gets committed; a "bad" note is still kept.
- Monotonic ratchet: PENDING → IN_PROGRESS → SEALED, never backward.
- The verifier owns PM status; the implementer never sets it itself.
- This repo has its own pre-existing `.claude/commands/ship.md` (keymap
  doc sync + commit/push) — that is NOT the kit's `/ship` skill (which
  lives at `.claude/skills/ship/SKILL.md`); the two are separate commands
  that happen to share a name pattern. Don't confuse them.
