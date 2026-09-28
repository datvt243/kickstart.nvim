# 2026-09-29 — dashboard-exclude-indent-guides — SHIP

- Node: `dashboard-exclude-indent-guides` (SEALED, see
  `evidence/verifier/2026-09-28/dashboard-exclude-indent-guides-seal.md`)
- Branch: `fix/dashboard-exclude-indent-guides` (auto-created off `master`
  by `/ship` step 0 — working tree was on `master` when `/ship` was
  invoked)
- Remote: `origin` → `https://github.com/datvt243/kickstart.nvim.git`
- Merge: `--merge=master` requested by operator

## Commands + output (verbatim)

`git checkout -b fix/dashboard-exclude-indent-guides master`
```
Switched to a new branch 'fix/dashboard-exclude-indent-guides'
```

`git add <7 node-scoped files>` (excluded `.claude/skills/ship/SKILL.md`
— unrelated, out-of-scope change left uncommitted)

`git commit -m "fix(indent-blankline): loại filetype dashboard khỏi indent guide lines..."`
```
[fix/dashboard-exclude-indent-guides c4333ae] fix(indent-blankline): loại filetype dashboard khỏi indent guide lines
 7 files changed, 255 insertions(+), 1 deletion(-)
 create mode 100644 agent-hub/evidence/implementer/2026-09-28/dashboard-exclude-indent-guides-diff.md
 create mode 100644 agent-hub/evidence/implementer/2026-09-28/dashboard-exclude-indent-guides-plan.md
 create mode 100644 agent-hub/evidence/verifier/2026-09-28/dashboard-exclude-indent-guides-seal.md
```

`git push -u origin fix/dashboard-exclude-indent-guides`
```
remote: Create a pull request for 'fix/dashboard-exclude-indent-guides' on GitHub by visiting:
remote:      https://github.com/datvt243/kickstart.nvim/pull/new/fix/dashboard-exclude-indent-guides
To https://github.com/datvt243/kickstart.nvim.git
 * [new branch]      fix/dashboard-exclude-indent-guides -> fix/dashboard-exclude-indent-guides
branch 'fix/dashboard-exclude-indent-guides' set up to track 'origin/fix/dashboard-exclude-indent-guides'.
```

`git checkout master && git pull origin master`
```
Switched to branch 'master'
Your branch is up to date with 'origin/master'.
Already up to date.
```

`git merge --no-ff fix/dashboard-exclude-indent-guides -m "Merge branch 'fix/dashboard-exclude-indent-guides'..."`
```
Merge made by the 'ort' strategy.
 7 files changed, 255 insertions(+), 1 deletion(-)
```

`git push origin master`
```
To https://github.com/datvt243/kickstart.nvim.git
   b94342d..ad60a22  master -> master
```

`git branch -d fix/dashboard-exclude-indent-guides && git push origin --delete fix/dashboard-exclude-indent-guides`
```
Deleted branch fix/dashboard-exclude-indent-guides (was c4333ae).
To https://github.com/datvt243/kickstart.nvim.git
 - [deleted]         fix/dashboard-exclude-indent-guides
```

## Final state
`git branch --show-current` → `master`
`git log --oneline -3`:
```
ad60a22 Merge branch 'fix/dashboard-exclude-indent-guides'
c4333ae fix(indent-blankline): loại filetype dashboard khỏi indent guide lines
b94342d chore: dọn healthcheck/ + issue/ đã resolve, đồng bộ README.md cấu trúc
```

## Seal gate
Full command sequence (commit → push → merge → push → cleanup) shown to
the operator in-session before running; operator approved with "ship có
--merge về master" then "chạy đi" (explicit go-ahead covering the whole
shown sequence, per this repo's stricter push rule requiring explicit
ask). Step 0's branch auto-creation ran without a separate ask, per
`/ship`'s own `BranchBeforeCommit` rule (local-only, non-outward-facing).
