# Constitution — {PROJECT NAME}

> Source of truth for the project. Non-negotiable. The agent must consult this file before any decision.

---

## Language Policy

**All artifacts written to disk must be in English** — `.md` files, configuration comments, code comments, commit messages, spec/task files, issue and PR descriptions.

This rule applies regardless of the spoken/chat language used with the agent. Conversations with the agent can be in any language; everything written to disk must be English.

**Why**: English yields the best LLM performance (largest training corpus, cleanest tokenization) and gives all shared tooling (grep, semantic search, embeddings) a consistent, predictable vocabulary.

---

## Development Principles

1. **Spec before code** — no implementation without an approved task
2. **Security is not optional** — every PR goes through the security checklist
3. **Documentation is part of the task** — not a separate step
4. **Least privilege always** — minimum permissions at every level
5. **Explicit context** — the agent does not assume, it asks
6. **Libraries before custom code** — prefer established solutions
7. **Conventional Commits** — every commit follows `type(scope): description`

---

## Naming Conventions

### Database

- Tables: `snake_case`, plural, with domain prefix (`auth_users`, `tenant_orgs`)
- Foreign keys: `{referenced_table_singular}_id`
- Indexes: `idx_{table}_{column}`
- Migrations: `{timestamp}_{snake_case_description}.sql`

### Code (TypeScript/React)

- Files: `kebab-case.ts` / `kebab-case.tsx`
- React components: `PascalCase.tsx`
- Functions and variables: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Types and interfaces: `PascalCase`
- Hooks: `use-{name}.ts`

### Code (Python)

- Files: `snake_case.py`
- Classes: `PascalCase`
- Functions and variables: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE`

### Branches and Worktrees

- Features: `feature/{number}-{kebab-name}`
- Tasks: `feature/{number}-{feature-name}/{number}-{task-name}`
- Hotfixes: `hotfix/{description}`
- Releases: `release/{version}`

### MCP Tools

- Format: `{domain}_{verb}_{resource}`
- Valid verbs: `get`, `list`, `create`, `update`, `delete`, `validate`
- Examples: `analytics_get_campaign_metrics`, `tenant_list_active`

---

## Security Principles

### Absolute Rules

- Zero secrets in code — always environment variables via `.env`
- Zero SQL string concatenation — always parameterized queries or ORM
- Zero user data in logs — mask PII before logging
- Zero unauthenticated endpoints (except explicitly public routes)
- Zero trust on client input — validate and sanitize on the server

### Authentication and Authorization

- Auth verified before any business logic
- Tokens with defined TTL and rotated refresh tokens
- Rate limiting on authentication endpoints
- Passwords hashed with bcrypt/argon2 — never MD5/SHA1

### Multi-tenancy (when applicable)

- Tenant ID validated on the server, never trusted from the client
- Row-level security on multi-tenant tables
- Logs segregated by tenant
- Zero cross-tenant access

### Dependencies

- Dependencies audited before adding (`npm audit` / `pip-audit`)
- HTTPS mandatory in all environments
- Security headers: CSP, HSTS, X-Frame-Options
- CORS restricted to explicit origins
- Dependabot enabled for automatic updates

---

## MCP Architecture Principles

### When to create an MCP Server

- When a module exposes **data or tools that an LLM needs to access**
- When end users interact with data via natural language
- **Do not create** for: ingestion pipelines, auth internals, batch jobs, CRON

### Tool Design

- Each tool has a single responsibility
- Read tools do not hold write credentials
- Every tool documents: description, parameters, return value, errors, minimum permission
- Tenant isolation validated inside each tool

### Registry

- Every tool registered in `docs/mcp-contracts.md` **before** implementation
- One MCP server per domain, not monolithic

---

## Code Quality

### Lint and Formatting

- **TypeScript/React**: Biome (replaces ESLint + Prettier)
- **Python**: Ruff (replaces Black + isort + Flake8)
- Run automatically on pre-commit and CI
- Zero warnings accepted in a PR

### Testing

- Framework defined per project (Vitest / Pytest recommended)
- Tests required for business logic and authentication
- Integration tests for critical endpoints
- Minimum coverage defined per project in `plan.md`

### Conventional Commits

Format: `type(scope): description`

Valid types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `security`

Examples:
- `feat(auth): add JWT refresh token rotation`
- `fix(dashboard): resolve tenant data leak in filter query`
- `docs(mcp): update analytics tool contract`
- `security(auth): add rate limiting to login endpoint`

### Changelog

- Generated automatically via Conventional Commits
- Format: Keep a Changelog (https://keepachangelog.com)
- Grouped by change type, not by date
- Maintained per feature, accumulated at release

---

## Workflow Rules

### Issues and Traceability

- 1 GitHub Issue = 1 Spec Kit task
- Milestone = feature/epic
- Subtasks = internal Issue checklist
- Every PR references the Issue: `closes #N`

### Worktrees

- Every task executed in an isolated worktree
- Merge with `--no-ff` to preserve history
- Worktree removed after merge is confirmed

### Rollback

- Tags created per feature on main: `v{feature}-done`
- Rollback via `git revert` on the merge commit
- Never `git reset --hard` on main

---

## Stack Decisions

Stack is defined per project during the `/speckit.plan` phase. The `docs/ARCHITECTURE-DECISIONS.md` template guides those decisions. This constitution does not prescribe tools — it prescribes **practices**.
