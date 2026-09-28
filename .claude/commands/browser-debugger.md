---
description: "Open a browser (Chrome/Firefox/Edge) with remote-debugging port 9888 so Claude can inspect/control it — optionally starting `npm run dev` first and pointing the browser at it. Usage: /browser-debugger [--browser=chrome|firefox|edge] [--run-dev]. Read-only dev utility, no code changes, no seal gate."
argument-hint: "[--browser=chrome|firefox|edge] [--run-dev]"
---

# /browser-debugger — open a browser with CDP debugging on port 9888

Local dev-environment utility only — never touches project source code,
never commits/pushes/deploys. `gate: none`, same class as `/hub-tokens`: no
seal gate, no evidence note, no worker identity needed.

## Steps
1. **Parse args.** `--browser=<name>` — one of `chrome`/`chromium`,
   `firefox`, `edge` (case-insensitive), default `chrome` if omitted or
   malformed — don't fail on a typo'd value, just tell the operator you
   fell back to the default. `--run-dev` — boolean flag, no value.
2. **If `--run-dev` was passed:**
   a. Check `package.json` at the repo root for a `scripts.dev` entry. Not
      present → skip starting anything, note "no `dev` script in
      package.json" in the final report, fall through to step 3 with the
      default target URL (`http://localhost:3000`).
   b. Present → detect the package manager from the lockfile
      (`package-lock.json` → `npm`, `yarn.lock` → `yarn`,
      `pnpm-lock.yaml` → `pnpm`; default `npm` if none found), then start
      `<pm> run dev` in the background (`run_in_background: true`),
      capture its output.
   c. Poll the dev server's own output for a local URL (common patterns:
      "Local:", "http://localhost:", "ready on") for up to ~15s. Found →
      use that URL as the target. Not found in time → fall back to
      `http://localhost:3000`, note in the report that the URL was
      guessed, not read from actual output.
3. **Resolve the browser executable** for `--browser` + the current OS
   (macOS/Linux/Windows) — real installed paths, don't assume:
   - macOS: `/Applications/Google Chrome.app/...`,
     `/Applications/Firefox.app/...`,
     `/Applications/Microsoft Edge.app/...`.
   - Linux: `google-chrome`/`chromium`, `firefox`, `microsoft-edge` on
     `$PATH`.
   - Windows (git-bash/WSL interop): standard `Program Files` install
     paths for each.
   Not found → report the real error (which path/command was tried) and
   stop — don't silently fall back to a different browser than requested.
4. **Launch** with remote debugging on port **9888**
   (`--remote-debugging-port=9888` for Chrome/Edge/Chromium;
   `--start-debugger-server 9888` for Firefox), pointed at the URL from
   step 2, as a background process. Capture the PID.
5. **Verify the debug port is actually responding** —
   `curl -fsS http://localhost:9888/json/version` (or equivalent), read
   the output back. Fails → report the real error, don't claim success.
6. **Report — confirm message, exactly these lines:**
   ```
   🌐 Browser: <chrome|firefox|edge> (PID <pid>)
   🔗 Debug port: localhost:9888 — <responding | not responding: reason>
   📍 URL: <url opened>
   🚀 Dev server: <started via <pm> run dev | already running | no dev script found | skipped (--run-dev not passed)>
   ```

## Failure branches
| Failure | Handling |
|---|---|
| Requested browser not installed / path not found | Report the exact path/command tried, stop — don't silently substitute another browser |
| Port 9888 already in use | Report it (`lsof -i :9888` output), ask whether to reuse the existing instance or stop — don't kill another process unasked |
| `--run-dev` passed but no `dev` script in `package.json` | Note it in the report, open the browser at the default URL instead of failing the whole command |
| Dev server starts but never prints a detectable local URL | Fall back to `http://localhost:3000`, say so plainly in the report — don't guess a wrong port silently |

## Runtime
`/browser-debugger [--browser=chrome|firefox|edge] [--run-dev]`. Purely
local: no git, no network call other than the local CDP check, no
project-file edits. Safe to re-run.
