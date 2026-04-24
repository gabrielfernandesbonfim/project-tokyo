# {PROJECT NAME}

## Context

{3-5 line description of the product, the problem it solves, and the target audience.}
{Fill in during /speckit.constitution or /speckit.specify.}

## Stack

{Defined during /speckit.plan — do not fill in before that.}

## Language Policy

All artifacts written to disk must be in English — `.md` files, configuration, code comments, commit messages, spec/task files, issue and PR descriptions. Conversations may be in any language; disk is English.

## Sources of truth (read on demand, do not embed)

- Non-negotiable rules: `.specify/memory/constitution.md`
- Architecture decisions: `docs/ARCHITECTURE-DECISIONS.md`
- MCP contracts: `docs/mcp-contracts.md`
- Module docs: `docs/modules/{module}.md` — load only the one you are touching

## Spec Kit

Spec-Driven Development. The constitution is the source of truth — consult it before naming artifacts or making architectural decisions.

Commands: `/speckit.constitution`, `/speckit.specify`, `/speckit.clarify`, `/speckit.plan`, `/speckit.tasks`, `/speckit.analyze`, `/speckit.implement`.

## Token economy

- Load only the context relevant to the current task
- Never load the full spec.md or tasks.md — reference specific sections
- Ask before loading another module's context
- Prefer pointers over embeds in any doc you write

## Defaults

- Never create secrets in code — use `.env`; never read `.env*` files
- Never make network calls not documented in the plan
- Ask before architectural decisions not covered in the spec
- Prefer established libraries over custom code
- Before committing: run lint (biome/ruff) and tests

## MCP policy

- Claude.ai account connectors are **disabled by default** in this project (`.claude/settings.json` sets `ENABLE_CLAUDEAI_MCP_SERVERS=false`)
- Project-specific MCP servers are declared in `.mcp.json` at the repo root (team-shared, committed)
- Contract first: register every tool in `docs/mcp-contracts.md` before implementing — use the `mcp-contract` skill

## Skills (triggered on demand — do not inline their content here)

- `worktree-workflow` — create, merge, and clean up task worktrees
- `security-checklist` — run before marking any task complete
- `mcp-contract` — register MCP tools before implementing them

## Docs to keep current

- `docs/modules/{module}.md` when modifying a module
- `docs/mcp-contracts.md` when creating/changing MCP tools
- `CHANGELOG.md` with Conventional Commits
