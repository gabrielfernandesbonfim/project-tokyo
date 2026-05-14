# Project Tokyo

Template for spec-driven development with **Claude Code** + **GitHub Spec Kit**.
Works for any software project — web, CLI, library, data pipeline, mobile, service.

## Use this template

1. Click **Use this template** on GitHub → create your repo
2. Clone locally
3. Initialize Spec Kit and the harness:

   ```bash
   specify init . --ai claude --ai-skills --force
   cp constitution.md .specify/memory/constitution.md && rm constitution.md
   pre-commit install
   ```

4. (Once per machine) copy user settings:

   ```bash
   mkdir -p ~/.claude && cp docs/claude-settings-user.json ~/.claude/settings.json
   ```

5. Open Claude Code and run the Spec Kit flow:

   ```
   /speckit.constitution → /speckit.specify → /speckit.clarify
   → /speckit.plan → /speckit.tasks → /speckit.analyze → /speckit.implement
   ```

Each task runs in an isolated worktree (`worktree-workflow` skill).

## What you get

- **Spec Kit enforced** — no code in implementation dirs without an active approved spec (hook-level, not honor-system)
- **Security baseline** — `.env`, `secrets/`, SSH keys, `git push --force`, dangerous `rm` blocked at hook level
- **Session context** — every session logs to `.claude/context/sessions/`; auto-pruned by count; `HISTORY.md` is committed and queryable
- **Defense in depth** — `settings.json` denies + bash hooks + harness-lock + pre-commit gitleaks + CI gitleaks
- **CI ready** — lint, tests, secrets scan, dependency audit, spec-check (PR fails without spec)
- **MCP opt-in** — `.mcp.json` empty by default; declare per project only if needed
- **Stack-neutral** — runtime and tooling chosen during `/speckit.plan`

## Files you customize first

| File | When |
|---|---|
| `constitution.md` | During `/speckit.constitution` |
| `CLAUDE.md` | Fill `Project Type` + `Implementation Directories` during `/speckit.plan` |
| `docs/ARCHITECTURE-DECISIONS.md` | During `/speckit.plan` |
| `.claude/context/state.json` | Mirror `implementation_dirs` from CLAUDE.md |
| `.mcp.json` | Only if exposing tools to LLMs |
| `.env.example` | Add keys (no values) as discovered |

## Read more

- **Setup detail & troubleshooting** → `docs/QUICKSTART.md`
- **How the harness works** → `docs/harness-architecture.md` (hooks, enforcement layers, session lifecycle)
- **Non-negotiable rules** → `constitution.md` (or `.specify/memory/constitution.md` after `specify init`)

## Language Policy

All on-disk artifacts in English. Conversations with the agent in any language. Rationale: English yields the best LLM performance and gives shared tooling (grep, embeddings) a consistent vocabulary.

## Recommended versions

| Tool | Version |
|---|---|
| Node.js | 24 LTS |
| Python | 3.13 |
| Git | 2.5+ |
| uv | latest |

## License

Defined per project.
