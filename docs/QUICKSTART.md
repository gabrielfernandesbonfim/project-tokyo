# Quickstart — Project Tokyo

Guia passo a passo: do zero ao primeiro `specify init`.

---

## 1. Pré-requisitos

### Node.js 24 LTS

```bash
# Instalar via nvm (recomendado)
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

### uv (package manager para Spec Kit)

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
# Seguir o fluxo interativo (GitHub.com → HTTPS → Login with browser)
```

### Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code
claude --version
```

### Ferramentas de qualidade

```bash
# Biome (lint + format para JS/TS)
npm install -g @biomejs/biome

# Ruff (lint + format para Python)
uv tool install ruff

# gitleaks (detecção de secrets)
# Baixar binário de https://github.com/gitleaks/gitleaks/releases
# Ou via snap:
sudo snap install gitleaks

# pre-commit (hooks automáticos)
uv tool install pre-commit
```

---

## 2. Configurar Claude Code (uma vez por máquina)

```bash
# Copiar settings de usuário
mkdir -p ~/.claude
cp docs/claude-settings-user.json ~/.claude/settings.json
```

O settings de usuário define:
- **Modelo padrão**: Sonnet (trocar para Opus manualmente com `/model opus` quando precisar)
- **Permissões deny**: bloqueia comandos destrutivos
- **Permissões allow**: libera ferramentas de desenvolvimento sem pedir confirmação
- **Telemetria desabilitada**

Para usar Opus: `/model opus` dentro do Claude Code (planejamento, arquitetura, decisões complexas).
Para extended thinking: adicionar `ultrathink` na mensagem quando necessário.

---

## 3. Criar novo projeto

### Opção A: Via GitHub (recomendado)

1. Ir em `github.com/{seu-user}/project-tokyo`
2. Clicar **Use this template** → **Create a new repository**
3. Nomear o repositório
4. Clonar localmente:

```bash
git clone git@github.com:{seu-user}/{novo-projeto}.git
cd {novo-projeto}
```

### Opção B: Manual

```bash
# Clonar o template
git clone git@github.com:{seu-user}/project-tokyo.git {novo-projeto}
cd {novo-projeto}

# Remover origin do template e apontar para novo repo
git remote remove origin
git remote add origin git@github.com:{seu-user}/{novo-projeto}.git
```

---

## 4. Inicializar Spec Kit

```bash
cd {novo-projeto}

# Inicializar com Claude Code + skills
specify init . --ai claude --ai-skills --force

# Verificar instalação
specify check
```

O `--force` é seguro aqui porque o template já contém os arquivos base. O Spec Kit vai adicionar sua estrutura `.specify/` e `.claude/commands/` (ou skills) sem apagar o que já existe.

### Mover constitution para o Spec Kit

```bash
# Copiar o template de constitution para onde o Spec Kit espera
cp constitution.md .specify/memory/constitution.md
```

### Configurar pre-commit hooks

```bash
pre-commit install
```

---

## 5. Iniciar desenvolvimento

```bash
# Abrir Claude Code
claude

# --- Fase de Conceito (usar /model opus) ---

/model opus

# Definir os princípios do projeto
/speckit.constitution

# Descrever O QUÊ você quer construir e POR QUÊ
# NÃO falar de tech stack aqui
/speckit.specify

# Resolver ambiguidades
/speckit.clarify

# --- Fase de Planejamento (continuar em Opus) ---

# Definir HOW: stack, arquitetura, banco, auth, deploy
# Aqui é onde as decisões de ferramentas acontecem
# Consultar docs/ARCHITECTURE-DECISIONS.md como guia
/speckit.plan

# Validar consistência
/speckit.analyze

# --- Fase de Execução (trocar para Sonnet) ---

/model sonnet

# Gerar tasks com checklists
/speckit.tasks

# Implementar task por task
/speckit.implement
```

---

## 6. Workflow de execução (por task)

Cada task segue este ciclo:

```bash
# 1. Criar worktree isolado
git worktree add ../{projeto}-{feature}-{task} -b feature/{feature}/{task}
cd ../{projeto}-{feature}-{task}

# 2. Implementar (dentro do Claude Code)
claude
# → trabalhar na task

# 3. Validar
# → lint passa (biome check / ruff check)
# → testes passam (vitest / pytest)
# → security checklist OK

# 4. Commitar
git add .
git commit -m "feat(scope): description"

# 5. Merge no branch da feature
cd ../{projeto}
git merge feature/{feature}/{task} --no-ff -m "task({numero}): {nome}"

# 6. Limpar
git worktree remove ../{projeto}-{feature}-{task}
git branch -d feature/{feature}/{task}
```

---

## 7. Fechar feature

```bash
# Atualizar docs
# → architecture.md, modules/{modulo}.md, mcp-contracts.md

# Criar PR
gh pr create \
  --title "feat({numero}): {nome da feature}" \
  --body "Closes #{issue-number}" \
  --base main \
  --head feature/{feature}

# Aguardar revisão e aprovar manualmente
# NUNCA merge automático no main
```

---

## 8. Gestão de secrets

```bash
# .env.example está commitado — documenta as chaves necessárias
# .env.local NÃO está commitado — contém valores reais

cp .env.example .env.local
# Editar .env.local com os valores reais

# Para CI/CD, usar GitHub Secrets:
gh secret set DATABASE_URL
gh secret set API_KEY
# (valores ficam no GitHub, não no código)
```

Para sincronizar entre máquinas: `.env.local` deve ser transferido manualmente (via gerenciador de senhas, USB, ou cloud pessoal segura). Nunca commitar.

---

## Referência rápida de comandos

| Ação | Comando |
|---|---|
| Trocar modelo | `/model opus` ou `/model sonnet` |
| Extended thinking | Adicionar `ultrathink` na mensagem |
| Ver worktrees | `git worktree list` |
| Criar worktree | `git worktree add ../{nome} -b {branch}` |
| Remover worktree | `git worktree remove ../{nome}` |
| Rodar lint JS/TS | `npx biome check .` |
| Rodar lint Python | `ruff check .` |
| Rodar testes JS/TS | `npx vitest run` |
| Rodar testes Python | `pytest` |
| Scan de secrets | `gitleaks detect` |
| Criar issue | `gh issue create` |
| Criar PR | `gh pr create` |
| Fechar issue | `gh issue close {N}` |
