# Quickstart — Project Tokyo

Step-by-step guide: from zero to your first `specify init`.

---

## 1. Prerequisites

### Node.js 24 LTS

```bash
# Install via nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
source ~/.bashrc
nvm install 24
nvm alias default 24
node --version  # v24.x.x
```

### Python 3.13

```bash
# Ubuntu/WSL
sudo apt update
sudo apt install python3.13 python3.13-venv python3-pip
python3 --version  # 3.13.x
```

### uv (package manager for Spec Kit)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
uv --version
```

### Git 2.5+

```bash
sudo apt install git
git --version
```

### GitHub CLI

```bash
sudo apt install gh
gh auth login
# Follow the interactive flow (GitHub.com → HTTPS → Login with browser)
```

### Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

### Quality tools

```bash
# Biome (lint + format for JS/TS)
npm install -g @biomejs/biome

# Ruff (lint + format for Python)
uv tool install ruff

# gitleaks (secrets detection)
# Download binary from https://github.com/gitleaks/gitleaks/releases
# Or via snap:
sudo snap install gitleaks

# pre-commit (automatic hooks)
uv tool install pre-commit
```

---

## 2. Configure Claude Code (once per machine)

```bash
# Copy user settings
mkdir -p ~/.claude
cp docs/claude-settings-user.json ~/.claude/settings.json
```

> **Warning**: This overwrites any existing `~/.claude/settings.json`. Back it up first if you have customizations.

The user settings define:
- **Default model**: Sonnet (switch to Opus manually with `/model opus` when needed)
- **Deny permissions**: blocks destructive commands
- **Allow permissions**: unlocks development tools without confirmation prompts
- **Telemetry disabled**

To use Opus: `/model opus` inside Claude Code (planning, architecture, complex decisions).
For extended thinking: add `ultrathink` to your message when needed.

---

## 3. Create a new project

### Option A: Via GitHub (recommended)

1. Go to `github.com/{your-user}/project-tokyo`
2. Click **Use this template** → **Create a new repository**
3. Name the repository
4. Clone locally:

```bash
git clone git@github.com:{your-user}/{new-project}.git
cd {new-project}
```

### Option B: Manual

```bash
# Clone the template
git clone git@github.com:{your-user}/project-tokyo.git {new-project}
cd {new-project}

# Remove template origin and point to new repo
git remote remove origin
git remote add origin git@github.com:{your-user}/{new-project}.git
```

---

## 4. Initialize Spec Kit

```bash
cd {new-project}

# Initialize with Claude Code + skills
specify init . --ai claude --ai-skills --force

# Verify installation
specify check
```

`--force` is safe here because the template already contains the base files. Spec Kit adds its `.specify/` and `.claude/commands/` (or skills) structure without overwriting existing files.

### Move the constitution to Spec Kit

```bash
# Copy the constitution template to where Spec Kit expects it
cp constitution.md .specify/memory/constitution.md

# The root constitution.md is now redundant — remove it
rm constitution.md
```

### Set up pre-commit hooks

```bash
pre-commit install
```

---

## 5. Start development

```bash
# Open Claude Code
claude

# --- Concept phase (use /model opus) ---

/model opus

# Define project principles
/speckit.constitution

# Describe WHAT you want to build and WHY
# Do NOT talk about tech stack here
/speckit.specify

# Resolve ambiguities
/speckit.clarify

# --- Planning phase (stay on Opus) ---

# Define HOW: stack, architecture, database, auth, deploy
# This is where tool decisions are made
# Consult docs/ARCHITECTURE-DECISIONS.md as a guide
/speckit.plan

# Validate consistency
/speckit.analyze

# --- Execution phase (switch to Sonnet) ---

/model sonnet

# Generate tasks with checklists
/speckit.tasks

# Implement task by task
/speckit.implement
```

---

## 6. Execution workflow (per task)

Each task follows this cycle:

```bash
# 1. Create isolated worktree
git worktree add ../{project}-{feature}-{task} -b feature/{feature}/{task}
cd ../{project}-{feature}-{task}

# 2. Implement (inside Claude Code)
claude
# → work on the task

# 3. Validate
# → lint passes (biome check / ruff check)
# → tests pass (vitest / pytest)
# → security checklist OK

# 4. Commit
git add .
git commit -m "feat(scope): description"

# 5. Merge into feature branch
cd ../{project}
git merge feature/{feature}/{task} --no-ff -m "task({number}): {name}"

# 6. Clean up
git worktree remove ../{project}-{feature}-{task}
git branch -d feature/{feature}/{task}
```

---

## 7. Close a feature

```bash
# Update docs
# → architecture.md, modules/{module}.md, mcp-contracts.md

# Create PR
gh pr create \
  --title "feat({number}): {feature name}" \
  --body "Closes #{issue-number}" \
  --base main \
  --head feature/{feature}

# Wait for review and approve manually
# NEVER auto-merge to main
```

---

## 8. MCP servers (per project)

Tokyo disables your Claude.ai account connectors (Apollo.io, Google Drive, Windsor.ai, etc.) **by default** in every new project. This keeps the per-session token baseline tight and forces explicit, project-scoped tool surfaces.

### How it works

- `.claude/settings.json` in the template sets `ENABLE_CLAUDEAI_MCP_SERVERS=false`
- Only MCP servers declared in the project (via `.mcp.json` or local scope) load
- Run `/mcp` inside Claude Code to see what is actually active

### Declare a project MCP server

`.mcp.json` lives at the repo root and is committed (team-shared). The template ships with it empty:

```json
{ "mcpServers": {} }
```

See `.mcp.json.example` for reference stanzas covering `stdio`, `http`, and `sse` transports, including environment expansion (`${VAR}`) for secrets.

Add servers via CLI (it writes to `.mcp.json` for you):

```bash
# Team-shared (writes to .mcp.json at repo root)
claude mcp add --transport http --scope project my-server https://mcp.example.com

# Or per-developer (not committed — goes to ~/.claude.json under this project)
claude mcp add --transport http my-server https://mcp.example.com
```

Register every tool in `docs/mcp-contracts.md` **before** implementing it. The `mcp-contract` skill guides this.

### If a project genuinely needs a Claude.ai connector

Remove or override the env var in `.claude/settings.json`:

```json
{
  "env": {
    "ENABLE_CLAUDEAI_MCP_SERVERS": "true"
  }
}
```

Do this deliberately per project — not by default.

---

## 9. Secrets management

```bash
# .env.example is committed — documents the required keys
# .env.local is NOT committed — contains real values

cp .env.example .env.local
# Edit .env.local with real values

# For CI/CD, use GitHub Secrets:
gh secret set DATABASE_URL
gh secret set API_KEY
# (values live in GitHub, not in code)
```

To sync between machines: `.env.local` must be transferred manually (via password manager, USB, or secure personal cloud). Never commit it.

---

## Quick command reference

| Action | Command |
|---|---|
| Switch model | `/model opus` or `/model sonnet` |
| Extended thinking | Add `ultrathink` to the message |
| List worktrees | `git worktree list` |
| Create worktree | `git worktree add ../{name} -b {branch}` |
| Remove worktree | `git worktree remove ../{name}` |
| Run JS/TS lint | `npx biome check .` |
| Run Python lint | `ruff check .` |
| Run JS/TS tests | `npx vitest run` |
| Run Python tests | `pytest` |
| Scan for secrets | `gitleaks detect` |
| List active MCP | `/mcp` inside Claude Code |
| Inspect context use | `/context` inside Claude Code |
| Create issue | `gh issue create` |
| Create PR | `gh pr create` |
| Close issue | `gh issue close {N}` |
