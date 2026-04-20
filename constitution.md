# Constitution — {NOME DO PROJETO}

> Fonte de verdade do projeto. Inegociável. O agente deve consultar este arquivo antes de qualquer decisão.

---

## Princípios de Desenvolvimento

1. **Spec antes de código** — nenhuma implementação sem task aprovada
2. **Segurança não é opcional** — todo PR passa pelo security checklist
3. **Documentação é parte da task** — não é etapa separada
4. **Menor privilégio sempre** — permissões mínimas em todo nível
5. **Contexto explícito** — agente não assume, pergunta
6. **Bibliotecas antes de código custom** — preferir soluções estabelecidas
7. **Conventional Commits** — todo commit segue o padrão `type(scope): description`

---

## Naming Conventions

### Banco de Dados

- Tabelas: `snake_case`, plural, com prefixo de domínio (`auth_users`, `tenant_orgs`)
- Chaves estrangeiras: `{tabela_referenciada_singular}_id`
- Índices: `idx_{tabela}_{coluna}`
- Migrations: `{timestamp}_{descricao_snake_case}.sql`

### Código (TypeScript/React)

- Arquivos: `kebab-case.ts` / `kebab-case.tsx`
- Componentes React: `PascalCase.tsx`
- Funções e variáveis: `camelCase`
- Constantes: `SCREAMING_SNAKE_CASE`
- Tipos e interfaces: `PascalCase`
- Hooks: `use-{nome}.ts`

### Código (Python)

- Arquivos: `snake_case.py`
- Classes: `PascalCase`
- Funções e variáveis: `snake_case`
- Constantes: `SCREAMING_SNAKE_CASE`

### Branches e Worktrees

- Features: `feature/{numero}-{nome-kebab}`
- Tasks: `feature/{numero}-{feature-nome}/{numero}-{task-nome}`
- Hotfixes: `hotfix/{descricao}`
- Releases: `release/{versao}`

### MCP Tools

- Formato: `{dominio}_{verbo}_{recurso}`
- Verbos válidos: `get`, `list`, `create`, `update`, `delete`, `validate`
- Exemplos: `analytics_get_campaign_metrics`, `tenant_list_active`

---

## Security Principles

### Regras Absolutas

- Zero secrets em código — sempre variáveis de ambiente via `.env`
- Zero SQL por concatenação de string — sempre queries parametrizadas ou ORM
- Zero dados de usuário em logs — mascarar PII antes de logar
- Zero endpoints sem autenticação (exceto rotas públicas explícitas)
- Zero confiança em input do cliente — validar e sanitizar no servidor

### Autenticação e Autorização

- Auth verificada antes de qualquer lógica de negócio
- Tokens com TTL definido e refresh tokens rotacionados
- Rate limiting em endpoints de autenticação
- Senhas hashadas com bcrypt/argon2 — nunca MD5/SHA1

### Multi-tenancy (quando aplicável)

- Tenant ID validado no servidor, nunca confiado do cliente
- Row-level security em tabelas multi-tenant
- Logs segregados por tenant
- Zero acesso cruzado entre tenants

### Dependências

- Dependências auditadas antes de adicionar (`npm audit` / `pip-audit`)
- HTTPS obrigatório em todos os ambientes
- Headers de segurança: CSP, HSTS, X-Frame-Options
- CORS restrito a origens explícitas
- Dependabot habilitado para atualizações automáticas

---

## MCP Architecture Principles

### Quando criar um MCP Server

- Quando um módulo expõe **dados ou ferramentas que uma LLM precisa acessar**
- Quando usuários finais interagem com dados via linguagem natural
- **Não criar** para: pipelines de ingestão, auth internals, jobs batch, CRON

### Design de Tools

- Cada tool tem responsabilidade única
- Tools de leitura não têm credenciais de escrita
- Toda tool documenta: descrição, parâmetros, retorno, erros, permissão mínima
- Tenant isolation validado dentro de cada tool

### Registro

- Toda tool registrada em `docs/mcp-contracts.md` **antes** de implementada
- MCP server por domínio, não monolítico

---

## Qualidade de Código

### Lint e Formatting

- **TypeScript/React**: Biome (substitui ESLint + Prettier)
- **Python**: Ruff (substitui Black + isort + Flake8)
- Executados automaticamente em pre-commit e CI
- Zero warnings aceitos em PR

### Testes

- Framework definido por projeto (Vitest / Pytest recomendados)
- Testes obrigatórios para lógica de negócio e autenticação
- Testes de integração para endpoints críticos
- Coverage mínimo definido por projeto no `plan.md`

### Conventional Commits

Formato: `type(scope): description`

Tipos válidos: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `security`

Exemplos:
- `feat(auth): add JWT refresh token rotation`
- `fix(dashboard): resolve tenant data leak in filter query`
- `docs(mcp): update analytics tool contract`
- `security(auth): add rate limiting to login endpoint`

### Changelog

- Gerado automaticamente via Conventional Commits
- Formato: Keep a Changelog (https://keepachangelog.com)
- Agrupado por tipo de mudança, não por data
- Mantido por feature, acumulado no release

---

## Workflow Rules

### Issues e Rastreabilidade

- 1 GitHub Issue = 1 task do Spec Kit
- Milestone = feature/epic
- Subtasks = checklist interno da Issue
- Todo PR referencia a Issue: `closes #N`

### Worktrees

- Toda task executada em worktree isolado
- Merge com `--no-ff` para preservar histórico
- Worktree removido após merge confirmado

### Rollback

- Tags criadas por feature no main: `v{feature}-done`
- Rollback via `git revert` no merge commit
- Nunca `git reset --hard` no main

---

## Decisões de Stack

Stack é definido por projeto na fase `/speckit.plan`. O template `docs/ARCHITECTURE-DECISIONS.md` guia as decisões. Esta constitution não prescreve ferramentas — prescreve **práticas**.
