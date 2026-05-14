#!/usr/bin/env bash
# .claude/hooks/security.sh
# PreToolUse hook — blocks access to secrets and dangerous bash commands.
# Defense layer 2: runs regardless of settings.json deny list.
# Exit 2 blocks the tool call and surfaces stderr to the agent.

set -euo pipefail

INPUT="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  printf 'SECURITY HOOK: jq not installed. Install jq (apt install jq / brew install jq).\n' >&2
  exit 0
fi

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')"

block() {
  printf 'SECURITY HOOK: %s\n' "$1" >&2
  exit 2
}

case "$TOOL_NAME" in
  Read|Edit|Write|MultiEdit)
    FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')"
    [ -z "$FILE_PATH" ] && exit 0
    NORM="${FILE_PATH#./}"

    # Allow documented templates that have no values
    case "$NORM" in
      *.env.example|.env.example) exit 0 ;;
    esac

    case "$NORM" in
      .env|.env.*|*/.env|*/.env.*)
        block "blocked access to $FILE_PATH (.env files are protected — use .env.example)" ;;
      secrets/*|*/secrets/*)
        block "blocked access to $FILE_PATH (secrets/ is protected)" ;;
      *.pem|*.key|*/id_rsa|*/id_ed25519|id_rsa|id_ed25519)
        block "blocked access to $FILE_PATH (key material is protected)" ;;
      *credentials.json|credentials.json)
        block "blocked access to $FILE_PATH (credentials file is protected)" ;;
    esac
    ;;

  Bash)
    CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')"
    [ -z "$CMD" ] && exit 0

    case "$CMD" in
      *"git push --force"*|*"git push -f "*|*"git push --force-with-lease"*)
        block "git force-push blocked. If truly needed, run from a terminal outside Claude." ;;
      *"git reset --hard"*)
        block "git reset --hard blocked. Prefer git revert or stash." ;;
      *"rm -rf /"*|*"rm -rf /*"*|*"rm -rf ~"*|*"rm -rf \$HOME"*|*"rm -rf .git"*)
        block "destructive rm blocked: $CMD" ;;
      "sudo "*|*" sudo "*|*";sudo "*|*"|sudo "*)
        block "sudo blocked. Run as your user, or do it manually outside Claude." ;;
      *"curl"*"| sh"*|*"curl"*"| bash"*|*"wget"*"| sh"*|*"wget"*"| bash"*)
        block "piping remote scripts to shell is blocked. Download, inspect, then run." ;;
      *"eval "*)
        block "eval is blocked." ;;
    esac
    ;;
esac

exit 0
