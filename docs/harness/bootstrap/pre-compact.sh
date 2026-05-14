#!/usr/bin/env bash
# .claude/hooks/pre-compact.sh
# PreCompact hook — dump state to a gitignored local snapshot the agent
# can re-read after compaction so context is not lost across the boundary.

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
STATE="$REPO_ROOT/.claude/context/state.json"
SNAP="$REPO_ROOT/.claude/context/sessions/precompact-snapshot.md"

{
  printf '# Pre-compact snapshot — %s\n\n' "$(date -Iseconds)"
  printf '## State (.claude/context/state.json)\n\n'
  printf '```json\n'
  if [ -f "$STATE" ]; then
    cat "$STATE"
  else
    printf '{}\n'
  fi
  printf '\n```\n\n'

  printf '## Git status\n\n'
  printf '```\n'
  git -C "$REPO_ROOT" status --short 2>/dev/null || true
  printf '```\n\n'

  printf '## Recent commits\n\n'
  printf '```\n'
  git -C "$REPO_ROOT" log --oneline -10 2>/dev/null || true
  printf '```\n'
} > "$SNAP"

exit 0
