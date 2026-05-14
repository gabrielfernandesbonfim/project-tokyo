#!/usr/bin/env bash
# .claude/hooks/session-end.sh
# Stop hook — append one sanitized line to HISTORY.md if the session
# produced commits or file changes. No prompts, no outputs — only metadata.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE="$REPO_ROOT/.claude/context/state.json"
SESS_DIR="$REPO_ROOT/.claude/context/sessions/recent"
HIST="$REPO_ROOT/.claude/context/sessions/HISTORY.md"
REF="$SESS_DIR/.session-start-ref"

[ -f "$HIST" ] || exit 0

SPEC="none"
PHASE="none"
if [ -f "$STATE" ] && command -v jq >/dev/null 2>&1; then
  s="$(jq -r '.active_spec // "none"' "$STATE")"
  [ -n "$s" ] && [ "$s" != "null" ] && SPEC="$s"
  p="$(jq -r '.active_phase // "none"' "$STATE")"
  [ -n "$p" ] && [ "$p" != "null" ] && PHASE="$p"
fi

START_REF=""
[ -f "$REF" ] && START_REF="$(cat "$REF" 2>/dev/null || true)"

COMMITS="none"
FILES="0"
if [ -n "$START_REF" ]; then
  C="$(git -C "$REPO_ROOT" log --pretty=%h "${START_REF}..HEAD" 2>/dev/null | paste -sd, - || true)"
  [ -n "$C" ] && COMMITS="$C"
  FILES="$(git -C "$REPO_ROOT" diff --name-only "${START_REF}..HEAD" 2>/dev/null | wc -l | tr -d ' ')"
  # Also include uncommitted changes count
  UNCOMMITTED="$(git -C "$REPO_ROOT" diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')"
  FILES=$((FILES + UNCOMMITTED))
fi

# Skip empty sessions (read-only / Q&A — nothing changed on disk)
if [ "$COMMITS" = "none" ] && [ "$FILES" = "0" ]; then
  rm -f "$REF"
  exit 0
fi

STAMP="$(date '+%Y-%m-%d %H:%M')"
LINE="${STAMP} | spec=${SPEC} | phase=${PHASE} | files=${FILES} | commits=${COMMITS} | note="

printf '%s\n' "$LINE" >> "$HIST"
rm -f "$REF"
exit 0
