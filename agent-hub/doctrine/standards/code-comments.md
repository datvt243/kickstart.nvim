> Comments explain what the code can't. Applies to every source file the
> project ships (not to `agent-hub/`, which has its own Style rule).

## Delete
- Restates the code or its type (a JSDoc `@return` repeating the real
  return type, a label like `// save` above `save()`).
- Says WHAT instead of WHY.
- Too obvious for the code it sits on.
- Commented-out code, empty placeholders, blank Author/Date templates.
- Issue/PR refs like `(#121)`, `(issue #N)` and narrated history ("found
  while building X") — that lives in git log/PR, not the source.

## Keep
- WHY behind non-obvious logic: invariants, workarounds, traps, security
  rationale — condensed to the essential point.
- JSDoc on public/exported functions and APIs, and functional doc blocks
  (e.g. `@swagger`) — never touched by a cleanup.
- `TODO`/`FIXME`/`HACK` markers.
- Links to external docs/specs.

## Style
| Use | For |
|---|---|
| `//` | 1-sentence note, TODO, logic inside a function body |
| `/** */` | JSDoc above a function/exported API; any explanation > 1 sentence |
Never stack several `//` lines for one multi-sentence explanation. Inside
`/** */`, never write `*/` in prose (e.g. a `**/*` glob) — it closes the
block early.

## Project opt-ins (OFF unless marked ON here)
- [ ] **File header** — every production source file (tests excluded)
  starts with a JSDoc block: `@author <<FILL: name + email>>` then
  `@see <<FILL: profile/repo URL>>`, tags after any real file-overview
  prose, merged into an existing overview block rather than stacked.
- [ ] **Object params** — a function/method/constructor taking > 2
  params takes one destructured object instead. Excluded: callbacks a
  framework calls positionally (Express `(req, res, next)`, error
  middleware detected by arity, multer/fs callbacks), test-local
  helpers, and existing dual-mode constructor overloads.

## Enforcement
Implementer: every comment the diff adds/changes follows the rules
above; the evidence note's `## Acceptance` carries one row "comments per
code-comments.md" citing the touched comments (or "no comments
touched"). A project-wide cleanup of existing comments is a separate
node, scoped per `initiative-scoping.md` — never folded into an
unrelated diff. Verifier: that row missing, or citing a rule violation →
REOPEN.
