#!/bin/sh
# agent-hub session hooks, wired in .claude/settings.json. Usage: hub-hook.sh start|compact
# start   = SessionStart: stdout is added to Claude's context.
# compact = PreCompact: stdout steers what the compaction summary keeps.
# Never blocks a session or a compaction: always exits 0.
HUB="${CLAUDE_PROJECT_DIR:-.}/agent-hub"
[ -d "$HUB/haven/diagrams" ] || exit 0
open=$(find "$HUB/haven/diagrams" -type f -name '*.md' ! -iname '*archive*' \
  -exec grep -hE '^\| [^|]+ \| (IN_PROGRESS|BLOCKED_[A-Za-z0-9_]+) \|' {} + 2>/dev/null)
case "$1" in
  start)
    echo "agent-hub: run /boot before new work (once per context; again after a compaction or /clear)."
    [ -n "$open" ] && printf 'Open nodes: resume in place, read the note in Notes (## Dead ends) first:\n%s\n' "$open" ;;
  compact)
    echo "agent-hub: the summary must keep, verbatim where possible: the node slug + state in progress, the worker role and recipe step reached, the evidence note path, each approach that failed with its error line, the next step, open questions for the operator. Paths, not file contents."
    [ -n "$open" ] && printf 'Open nodes at compaction:\n%s\n' "$open" ;;
esac
exit 0
