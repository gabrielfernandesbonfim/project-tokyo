# {PROJECT NAME}

## Context

{3-5 line description of the product, the problem it solves, and the target audience.}
{Fill in during the /speckit.constitution or /speckit.specify phase.}

## Stack

{Defined during the /speckit.plan phase — do not fill in before that.}

## Language Policy

**All artifacts written to disk must be in English** — `.md` files, configuration comments, code comments, commit messages, spec/task files, issue and PR descriptions. Conversations with the user can be in any language; everything written to disk must be English.

## Spec Kit

This project uses Spec-Driven Development via the GitHub Spec Kit.
Read `.specify/memory/constitution.md` first — it is the source of truth.
Everything there is non-negotiable.

### Available commands

- `/speckit.constitution` — define project principles
- `/speckit.specify` — create the spec (WHAT, not HOW)
- `/speckit.clarify` — resolve ambiguities in the spec
- `/speckit.plan` — technical plan + architecture decisions
- `/speckit.tasks` — generate tasks with security checklist
- `/speckit.analyze` — validate consistency across artifacts
- `/speckit.implement` — execute implementation

## Agent: Behavior Rules

### Minimal Context (Token Economy)

- Load ONLY context relevant to the current task
- Never load the full spec.md — reference specific sections
- Never load the full tasks.md — work task by task
- architecture.md: load once per session, reference by name afterwards
- If context from another module is needed, ask explicitly with justification

### Default Behavior

- Always check constitution.md before naming any artifact
- Always check docs/mcp-contracts.md before creating a new MCP integration
- Never create secrets, credentials, or tokens in code — always use .env
- Never make network calls not documented in the plan
- Ask before making architectural decisions not covered in the spec
- Prefer established libraries over implementing from scratch
- When finishing a task, run lint (biome/ruff) and tests before committing

### Worktree Workflow

Every task must be executed in an isolated worktree:

```bash
# Create worktree
git worktree add ../{project}-{feature}-{task} feature/{feature}/{task}

# When task is complete
git checkout feature/{feature}
git merge feature/{feature}/{task} --no-ff -m "task({number}): {name}"
git worktree remove ../{project}-{feature}-{task}
git branch -d feature/{feature}/{task}
```

### Security

Before marking any task as complete:

- [ ] Inputs validated and sanitized on the server
- [ ] Authentication verified before business logic
- [ ] Parameterized queries — zero string interpolation in SQL
- [ ] No sensitive data in logs or error responses
- [ ] Secrets in environment variables — none hardcoded
- [ ] Dependencies audited (npm audit / pip-audit)

### Documentation

- Update `docs/modules/{module}.md` when modifying a module
- Update `docs/mcp-contracts.md` if a new MCP tool is created
- Keep CHANGELOG.md updated with Conventional Commits

## References

- Conventions: `.specify/memory/constitution.md`
- Architecture: `docs/architecture.md`
- MCP contracts: `docs/mcp-contracts.md`
