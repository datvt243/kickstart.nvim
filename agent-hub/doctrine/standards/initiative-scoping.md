> "The baseline you measure is the baseline you'll be judged against —
> measure it with the same tool you'll use to confirm you're done, or
> you're not actually measuring anything." Applies to any "clean up X
> across the whole codebase" initiative: lint rules, type coverage,
> dependency upgrades, security findings — anything framed as a numeric
> problem count.

## The rule
Before splitting a measured-by-count initiative into phases, run the
exhaustive, machine-readable measurement (e.g. `--format json`, not a
bare terminal scroll) and group it by BOTH rule/category AND file. Plan
phases from that table — never from manual grep sampling, memory of
"the files that seemed bad," or a single un-decomposed total number.

After the LAST phase, re-run the SAME full measurement used to define
the starting baseline, and diff the before/after counts per rule. A
phase's own narrower verification (the project's own test/build
command) checks that phase's own change — it does not, and cannot,
confirm the initiative's own stated goal was reached.

## Not evidence vs Evidence
| Not evidence | Evidence |
|---|---|
| "The linter reported N problems, so we have N of [the target pattern] to fix" | `--format json` grouped by rule: how many are actually the target rule? |
| "I grepped for it and picked the worst-looking files" | A table of every file with a real hit, built once, exhaustively |
| "All phases are done, the project's own test/build is clean" | Re-ran the SAME tool that defined "not done" and the count actually dropped to the claimed number |
| "The initiative is complete" | The after-measurement's per-rule breakdown has zero in every rule the initiative claimed to fix, and anything left is named as explicitly out of scope |

## Why this matters
A multi-phase cleanup can declare victory once its own phases' narrower
checks (compiler, tests, build) all pass, while a chunk of the original
problem was never scoped in — because the phases were carved up by
hand-picking the worst-looking files instead of an exhaustive rule+file
breakdown of the real baseline. The gap only surfaces when someone
re-runs the SAME full measurement used at the start, or hand-reviews the
result — both of which should have happened before declaring done, not
after. A related trap: the original baseline number is often a mix of
unrelated categories (e.g. a lint total that's mostly one unrelated
rule/config issue, nothing to do with the initiative's actual target) —
breaking it down by rule BEFORE planning phases is what catches that
early instead of leaving it invisible in the total.

## What "measure exhaustively" means
Run the tool with a structured output format, parse it, and produce two
views before writing a single phase description: total count grouped by
rule/category, and total count grouped by file. Phases get carved from
THAT data. A category unrelated to the initiative's actual target gets
split into its own separate issue, not silently folded in or silently
dropped.

## No exceptions
"Each phase's own narrower check is clean" is never substituted for the
initiative-level re-measurement, no matter how confident the individual
phases felt. If the full measurement hasn't been re-run after the last
phase, the initiative is not done — it's `blocked` on that re-run, same
as any other unverified claim.

## Failure mode this catches
"Narrow-tool false completion" — every individual phase's own
verification was real and honest, but the initiative as a whole was
declared done using a DIFFERENT, narrower tool than the one that
defined "not done" in the first place.

## Enforcement
Implementer: when scoping a new measured-by-count initiative, the FIRST
artifact (before any phase description, before any issue) is the
rule+file breakdown table. Verifier: on the node that claims to be the
LAST phase of such an initiative, re-run the full original measurement
yourself and confirm the per-rule counts the implementer claims —
treating the initiative's aggregate claim with the same scrutiny as any
other numeric claim, not just each phase's own narrower diff.
