#!/usr/bin/env bash
# .claude/hooks/session-start.sh
# SessionStart hook — prune recent/ by file count, init today's log,
# emit last HISTORY line so the agent picks up continuity.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE="$REPO_ROOT/.claude/context/state.json"
SESS_DIR="$REPO_ROOT/.claude/context/sessions/recent"
HIST="$REPO_ROOT/.claude/context/sessions/HISTORY.md"

mkdir -p "$SESS_DIR"

COUNT=20
if [ -f "$STATE" ] && command -v jq >/dev/null 2>&1; then
  v="$(jq -r '.session_retention_count // 20' "$STATE")"
  [ -n "$v" ] && [ "$v" != "null" ] && COUNT="$v"
fi

# Prune oldest files in recent/ beyond COUNT (ignore .gitkeep and dotfiles)
mapfile -t FILES < <(find "$SESS_DIR" -maxdepth 1 -type f \
  ! -name '.gitkeep' ! -name '.session-start-ref' \
  -printf '%T@ %p\n' 2>/dev/null | sort -n | awk '{print $2}')
N="${#FILES[@]}"
if [ "$N" -gt "$COUNT" ]; then
  DROP=$((N - COUNT))
  for ((i=0; i<DROP; i++)); do rm -f -- "${FILES[i]}"; done
fi

# One log file per day (idempotent across restarts on the same day)
TODAY="$(date +%Y-%m-%d)"
LOG="$SESS_DIR/${TODAY}.md"
[ -f "$LOG" ] || printf '# Session %s\n\n' "$TODAY" > "$LOG"

# Record start ref for session-end to compute diff range
START_COMMIT="$(git -C "$REPO_ROOT" rev-parse HEAD 2>/dev/null || echo "")"
printf '%s\n' "$START_COMMIT" > "$SESS_DIR/.session-start-ref"

# Update state.json last_session
if [ -f "$STATE" ] && command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  jq --arg t "$(date -Iseconds)" '.last_session = $t' "$STATE" > "$tmp" && mv "$tmp" "$STATE"
fi

# Surface last HISTORY line to the agent
if [ -f "$HIST" ]; then
  LAST="$(grep -E '^[0-9]{4}-[0-9]{2}-[0-9]{2}' "$HIST" | tail -1 || true)"
  [ -n "$LAST" ] && printf 'Last session: %s\n' "$LAST"
fi

exit 0
