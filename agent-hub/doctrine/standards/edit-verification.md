> "You may not claim an outcome you have not observed." The most
> commonly violated rule in agent work. Exceptions: None.

## The rule
You may only report completion once the output has actually been
produced and read back — not once you think the edit is correct.

## Not evidence vs Evidence
| Not evidence | Evidence |
|---|---|
| "This fix should resolve the bug" | Ran it again, read the real output |
| "Tests should pass now" | `[1/3] load config... ✓` / `Kết quả tổng: PASS (0 ERROR)` (verbatim from `./scripts/health.sh`) |

## Why reasoning doesn't count
Reasoning about code is not the same as running code. Models tend to
trust their own description more than an actual check.

## What read back means
Copy the EXACT command verbatim from `doctrine/MEMORY.md`, run it, read
the result verbatim, write it into the evidence note — no paraphrasing,
no summarizing into your own conclusion.

## No Exceptions
Can't verify it yet → report `blocked`. There's no "probably fine"
exception.

## Failure mode this catches
"Green-by-supposition" — claiming a test passed without actually running
it.

## Enforcement
Implementer: hard rule `TestsBeforeDone`. Verifier: hard rule
`EvidencePerAction` — a claim without enough evidence → REOPEN. Related:
`EDIT_UNVERIFIED`.
