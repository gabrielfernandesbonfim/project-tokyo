# Harness bootstrap — installing the session-lifecycle hooks

These three scripts (`session-start.sh`, `session-end.sh`, `pre-compact.sh`) live here as a staging area because **harness-lock** blocks the agent from writing inside `.claude/hooks/` or editing `.claude/settings.json`. They need a one-time manual install — run by you, outside the agent.

## Why a staging step?

`harness-lock.sh` (PreToolUse) blocks any `Edit|Write|MultiEdit` whose target matches `.claude/hooks/*` or `.claude/settings.json`. That is the whole point — it prevents the agent from removing its own enforcement. The trade-off is that *adding* hooks also has to happen outside the agent.

## Install

From the repo root:

```bash
# 1. Move scripts into place
mv docs/harness/bootstrap/session-start.sh .claude/hooks/
mv docs/harness/bootstrap/session-end.sh   .claude/hooks/
mv docs/harness/bootstrap/pre-compact.sh   .claude/hooks/

# 2. Make them executable
chmod 755 .claude/hooks/session-start.sh \
          .claude/hooks/session-end.sh \
          .claude/hooks/pre-compact.sh
```

## Register in `.claude/settings.json`

Open `.claude/settings.json` and add the following three top-level keys inside the existing `"hooks": { ... }` object, alongside `"PreToolUse"`:

```json
"SessionStart": [
  {
    "matcher": "*",
    "hooks": [
      { "type": "command", "command": ".claude/hooks/session-start.sh" }
    ]
  }
],
"Stop": [
  {
    "matcher": "*",
    "hooks": [
      { "type": "command", "command": ".claude/hooks/session-end.sh" }
    ]
  }
],
"PreCompact": [
  {
    "matcher": "*",
    "hooks": [
      { "type": "command", "command": ".claude/hooks/pre-compact.sh" }
    ]
  }
]
```

## Verify

After install, start a new Claude session — `session-start.sh` should print one of:
- nothing (if `HISTORY.md` has no entries yet)
- `Last session: <line>` (when there is prior history)

End the session (Stop event). If you committed or touched files, a new line appears in `.claude/context/sessions/HISTORY.md`. Empty sessions are skipped.

To test `pre-compact.sh` without waiting for a real compaction, run it directly:

```bash
.claude/hooks/pre-compact.sh
cat .claude/context/sessions/precompact-snapshot.md
```

## After install

Once the hooks are in place and verified, this `docs/harness/bootstrap/` directory can be removed — it exists only to ferry files past `harness-lock`. The same staging pattern applies to any future hook you want to add.
