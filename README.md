# Project Tokyo

Framework de desenvolvimento AI-driven para projetos web. Combina **Spec Kit** (spec-driven development) com **Claude Code CLI** para criar um workflow reproduzível, seguro e escalável.

## O que é

Um repositório template no GitHub. Para cada novo projeto, faça **Use this template** e comece com toda a estrutura pronta: constitution, CLAUDE.md, CI/CD, settings, e o workflow spec → plan → tasks → implement do Spec Kit.

## Stack do Framework (não do projeto)

O framework é agnóstico a stack. Cada projeto define suas ferramentas na fase de arquitetura (`/speckit.plan`). O que o Tokyo padroniza:

- **Metodologia**: Spec Kit (GitHub) — spec-driven development
- **Agente**: Claude Code CLI com skills (`--ai-skills`)
- **Versionamento**: Git + GitHub (Issues, PRs, Actions)
- **Qualidade**: Biome (JS/TS) + Ruff (Python) — lint e formatting automáticos
- **Testes**: Vitest (JS/TS) + Pytest (Python) — definidos por projeto
- **CI/CD**: GitHub Actions — lint → test → security scan
- **Segurança**: gitleaks (pre-commit), Dependabot, npm audit / pip-audit

## Quickstart

```bash
# 1. Pré-requisitos (executar dentro do WSL ou Linux)
git --version          # 2.5+
node --version         # 24 LTS
python3 --version      # 3.13
gh auth login          # GitHub CLI autenticado
npm install -g @anthropic-ai/claude-code

# 2. Instalar Spec Kit CLI
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 3. Criar projeto a partir do template
# → No GitHub, clique "Use this template" neste repo
# → Clone o novo repo localmente

# 4. Inicializar Spec Kit
cd meu-projeto
specify init . --ai claude --ai-skills --force

# 5. Copiar settings de usuário (uma vez por máquina)
cp docs/claude-settings-user.json ~/.claude/settings.json

# 6. Abrir Claude Code e começar
claude
```

## Workflow Resumido

```
/speckit.constitution  →  Definir princípios do projeto
/speckit.specify       →  Descrever O QUÊ e POR QUÊ (sem tech stack)
/speckit.clarify       →  Resolver ambiguidades
/speckit.plan          →  Definir HOW: stack, arquitetura, MCP surface
/speckit.tasks         →  Gerar tasks com checklists de segurança
/speckit.analyze       →  Validar consistência entre artefatos
/speckit.implement     →  Executar task por task com worktrees isolados
```

## Estrutura do Repositório

```
project-tokyo/
├── .claude/
│   └── settings.json          # Settings de projeto (commitado)
├── .github/
│   └── workflows/
│       └── ci.yml             # CI: lint, test, security
├── docs/
│   ├── QUICKSTART.md          # Passo a passo detalhado
│   ├── ARCHITECTURE-DECISIONS.md  # Template de decisões por projeto
│   ├── claude-settings-user.json  # Settings de usuário (copiar p/ ~/.claude/)
│   └── mcp-contracts.md       # Template de contratos MCP
├── .env.example               # Chaves sem valores — documentação de envs
├── .gitignore
├── .pre-commit-config.yaml    # gitleaks + formatação
├── CLAUDE.md                  # Instruções para o agente
├── constitution.md            # → movido para .specify/ após specify init
└── README.md
```

> **Nota**: Após `specify init`, a constitution vai para `.specify/memory/constitution.md`. O arquivo `constitution.md` na raiz é o template — copie o conteúdo para lá.

## Documentação

- **[QUICKSTART.md](docs/QUICKSTART.md)** — Guia completo de setup e uso
- **[ARCHITECTURE-DECISIONS.md](docs/ARCHITECTURE-DECISIONS.md)** — Template para decisões de stack
- **[mcp-contracts.md](docs/mcp-contracts.md)** — Template de contratos MCP

## Versões recomendadas

| Ferramenta | Versão | Motivo |
|---|---|---|
| Node.js | 24 LTS | Suporte até abril 2028 |
| Python | 3.13 | Estável, compatibilidade total com libs |
| Git | 2.5+ | Worktree support |
| uv | latest | Package manager para Spec Kit |

## Licença

Definir por projeto.
