# Project Tokyo

AI-driven development framework for web projects. Combines **Spec Kit** (spec-driven development) with the **Claude Code CLI** to produce a reproducible, secure, and scalable workflow.

## What it is

A GitHub template repository. For each new project, click **Use this template** and start with the full structure ready: constitution, CLAUDE.md, CI/CD, settings, and the Spec Kit spec → plan → tasks → implement workflow.

## Framework Stack (not the project's)

The framework is stack-agnostic. Each project defines its tools during the architecture phase (`/speckit.plan`). What Tokyo standardizes:

- **Methodology**: Spec Kit (GitHub) — spec-driven development
- **Agent**: Claude Code CLI with skills (`--ai-skills`)
- **Versioning**: Git + GitHub (Issues, PRs, Actions)
- **Quality**: Biome (JS/TS) + Ruff (Python) — automatic lint and formatting
- **Testing**: Vitest (JS/TS) + Pytest (Python) — defined per project
- **CI/CD**: GitHub Actions — lint → test → security scan
- **Security**: gitleaks (pre-commit), Dependabot, npm audit / pip-audit

## Quickstart

```bash
# 1. Prerequisites (run inside WSL or Linux)
git --version          # 2.5+
node --version         # 24 LTS
python3 --version      # 3.13
gh auth login          # GitHub CLI authenticated
npm install -g @anthropic-ai/claude-code

# 2. Install Spec Kit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 3. Create project from the template
# → On GitHub, click "Use this template" on this repo
# → Clone the new repo locally

# 4. Initialize Spec Kit
cd my-project
specify init . --ai claude --ai-skills --force

# 5. Copy user settings (once per machine)
cp docs/claude-settings-user.json ~/.claude/settings.json

# 6. Open Claude Code and start
claude
```

## Workflow Summary

```
/speckit.constitution  →  Define project principles
/speckit.specify       →  Describe WHAT and WHY (no tech stack)
/speckit.clarify       →  Resolve ambiguities
/speckit.plan          →  Define HOW: stack, architecture, MCP surface
/speckit.tasks         →  Generate tasks with security checklists
/speckit.analyze       →  Validate consistency across artifacts
/speckit.implement     →  Execute task by task in isolated worktrees
```

## Repository Structure

```
project-tokyo/
├── .claude/
│   ├── settings.json          # Project settings (committed)
│   └── skills/                # Lazy-loaded workflows (triggered on demand)
│       ├── worktree-workflow/ # Worktree create/merge/cleanup
│       ├── security-checklist/# Pre-complete security gates
│       └── mcp-contract/      # MCP tool registration rules
├── .github/
│   └── workflows/
│       └── ci.yml             # CI: lint, test, security
├── docs/
│   ├── QUICKSTART.md          # Detailed step-by-step guide
│   ├── ARCHITECTURE-DECISIONS.md  # Per-project decisions template
│   ├── claude-settings-user.json  # User settings (copy to ~/.claude/)
│   └── mcp-contracts.md       # MCP contracts template
├── .env.example               # Keys without values — env documentation
├── .mcp.json                  # Project-scoped MCP servers (empty by default)
├── .mcp.json.example          # MCP stanza reference (stdio / http / sse)
├── .gitignore
├── .pre-commit-config.yaml    # gitleaks + formatting
├── CLAUDE.md                  # Minimal agent instructions (pointers, not embeds)
├── constitution.md            # → moved to .specify/ after specify init
└── README.md
```

> **Context budget**: `CLAUDE.md` is intentionally short — it only holds rules that must apply to every turn. Procedural know-how (worktree, security, MCP) lives in `.claude/skills/*` and is injected only when the agent needs it.

> **Note**: After `specify init`, the constitution moves to `.specify/memory/constitution.md`. The `constitution.md` file at the root is the template — copy its contents there.

## Documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)** — Full setup and usage guide
- **[ARCHITECTURE-DECISIONS.md](docs/ARCHITECTURE-DECISIONS.md)** — Stack decisions template
- **[mcp-contracts.md](docs/mcp-contracts.md)** — MCP contracts template

## Language Policy

All project artifacts written to disk — `.md` files, configuration, code comments, commit messages, issue/PR descriptions, spec/task files — must be in **English**, regardless of the spoken/chat language used with the agent. Rationale: English yields the best LLM performance (largest training corpus, cleanest tokenization) and gives shared tooling a consistent vocabulary. See `constitution.md` for the full rule.

## Recommended Versions

| Tool | Version | Reason |
|---|---|---|
| Node.js | 24 LTS | Supported until April 2028 |
| Python | 3.13 | Stable, full library compatibility |
| Git | 2.5+ | Worktree support |
| uv | latest | Package manager for Spec Kit |

## License

Defined per project.
