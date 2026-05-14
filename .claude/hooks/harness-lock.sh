#!/usr/bin/env bash
# .claude/hooks/harness-lock.sh
# PreToolUse hook — prevents the agent from modifying its own enforcement layer.
# Humans edit these files in their editor; the agent does not touch them in-session.

set -euo pipefail

INPUT="$(cat)"

command -v jq >/dev/null 2>&1 || exit 0

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
case "$TOOL_NAME" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
[ -z "$FILE_PATH" ] && exit 0

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
case "$FILE_PATH" in
  /*) REL_PATH="${FILE_PATH#$REPO_ROOT/}" ;;
  *)  REL_PATH="$FILE_PATH" ;;
esac
REL_PATH="${REL_PATH#./}"

case "$REL_PATH" in
  .claude/hooks/*|.claude/settings.json)
    printf 'HARNESS-LOCK: %s is protected from in-session edits.\nModify it manually in your editor outside Claude.\nThis prevents the agent from removing its own enforcement layer.\n' "$REL_PATH" >&2
    exit 2
    ;;
esac

exit 0
