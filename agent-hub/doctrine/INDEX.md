# doctrine/INDEX.md — a map of doctrine

> Doctrine is VERIFIED TRUTH. Guesses and half-finished ideas do NOT
> belong here — they belong in an `evidence/` note or a diagram note.

## Read in this order
| File | What it is | When you need it |
|---|---|---|
| `SOUL.md` | The hub agent's identity | Before deciding to change anything on your own |
| `MEMORY.md` | Path, stack, exact commands | Every session, right at the start |
| `domains/PROJECT.md` | The project's own ground truth | Before implementing |
| `standards/edit-verification.md` | The rule against claiming what hasn't been observed | Before reporting "done" |
| `standards/recipes.md` | What a recipe is, when to write one | The 2nd time you repeat a process |

## The three kinds of knowledge here
| Kind | Home | Example |
|---|---|---|
| About the hub | `SOUL.md` / `MEMORY.md` | The exact healthcheck command |
| About the domain/project | `domains/<project>.md` | An invariant specific to this config |
| About how to work | `standards/*.md` | The mandatory recipe format |

A fact living in the wrong drawer is a fact no one trusts.

## Growing the doctrine
Only add a file/section when ALL 3 are true: (1) verified, (2) durable,
(3) NOT INFERABLE — an agent reading the code for 2 minutes couldn't
figure it out on its own. Fails (3)? Don't write it — doctrine that just
echoes the code will silently go stale and mislead the reader.

## Correcting the doctrine
Fix the file, AND record "what I used to believe / what's actually true"
in the Corrections table in the related worker's `MEMORY.md`. Silently
deleting a wrong fact also erases the lesson behind it.

## Deliberately absent
No `laws/`, `architecture/`, `uplifts/`, `training/`. Only add these once
there's a real lesson that actually needs them — never add them ahead of
time.
