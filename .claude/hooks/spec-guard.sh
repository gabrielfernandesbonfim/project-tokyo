#!/usr/bin/env bash
# .claude/hooks/spec-guard.sh
# PreToolUse hook — blocks writes to implementation dirs without an active approved spec.
# Reads .claude/context/state.json to know what's active and what counts as implementation.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  printf 'SPEC-GUARD: jq not installed; cannot enforce.\n' >&2
  exit 0
fi

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"
case "$TOOL_NAME" in
  Write|Edit|MultiEdit) ;;
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

# Allowlist — always permitted regardless of spec state
case "$REL_PATH" in
  .claude/*|.specify/*|specs/*|docs/*|tests/*|test/*|.github/*) exit 0 ;;
  .gitignore|.env.example|.mcp.json|.mcp.json.example|.pre-commit-config.yaml) exit 0 ;;
  CLAUDE.md|README.md|CHANGELOG.md|LICENSE|constitution.md) exit 0 ;;
  package.json|tsconfig.json|biome.json|ruff.toml|pyproject.toml|setup.cfg|setup.py|Cargo.toml|go.mod|go.sum) exit 0 ;;
  *.md) exit 0 ;;
esac

STATE="$REPO_ROOT/.claude/context/state.json"
if [ ! -f "$STATE" ]; then
  exit 0  # bootstrap: harness state not yet set up
fi

ACTIVE_SPEC="$(jq -r '.active_spec // empty' "$STATE")"
DIRS="$(jq -r '.implementation_dirs[]? // empty' "$STATE")"
if [ -z "$DIRS" ]; then
  DIRS=$'src/\nlib/\napp/\npkg/\ninternal/\ncmd/\napi/'
fi

IS_IMPL=0
while IFS= read -r dir; do
  [ -z "$dir" ] && continue
  dir="${dir%/}/"
  case "$REL_PATH" in
    "$dir"*) IS_IMPL=1; break ;;
  esac
done <<< "$DIRS"

[ "$IS_IMPL" -eq 0 ] && exit 0

if [ -z "$ACTIVE_SPEC" ]; then
  printf 'SPEC-GUARD: attempted write to %s without an active spec.\nRun /speckit.specify <description>, then /spec-activate <slug>.\nSee CLAUDE.md §Spec Kit.\n' "$REL_PATH" >&2
  exit 2
fi

# Verify the active spec exists on disk (post-init in .specify/, pre-init in specs/)
if [ ! -f "$REPO_ROOT/.specify/specs/$ACTIVE_SPEC/spec.md" ] && \
   [ ! -f "$REPO_ROOT/specs/$ACTIVE_SPEC/spec.md" ]; then
  printf 'SPEC-GUARD: state.json points to active_spec=%s but its spec.md was not found.\nFix state.json or run /spec-activate <existing-slug>.\n' "$ACTIVE_SPEC" >&2
  exit 2
fi

exit 0
