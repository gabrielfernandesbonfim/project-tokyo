# {NOME DO PROJETO}

## Contexto

{Descrição de 3-5 linhas do produto, problema que resolve, público-alvo.}
{Preencher na fase /speckit.constitution ou /speckit.specify.}

## Stack

{Definido na fase /speckit.plan — não preencher antes.}

## Spec Kit

Este projeto usa Spec-Driven Development via GitHub Spec Kit.
Leia `.specify/memory/constitution.md` primeiro — é a fonte de verdade.
Tudo que está lá é inegociável.

### Comandos disponíveis

- `/speckit.constitution` — definir princípios do projeto
- `/speckit.specify` — criar spec (O QUÊ, não COMO)
- `/speckit.clarify` — resolver ambiguidades na spec
- `/speckit.plan` — plano técnico + decisões de arquitetura
- `/speckit.tasks` — gerar tasks com security checklist
- `/speckit.analyze` — validar consistência entre artefatos
- `/speckit.implement` — executar implementação

## Agente: Regras de Comportamento

### Contexto Mínimo (Token Economy)

- Carregar APENAS o contexto relevante para a task atual
- Nunca carregar spec.md completo — referenciar seções específicas
- Nunca carregar tasks.md completo — trabalhar task por task
- architecture.md: carregar uma vez por sessão, referenciar por nome depois
- Se precisar de contexto de outro módulo, pedir explicitamente com justificativa

### Comportamento Padrão

- Sempre verificar constitution.md antes de nomear qualquer artefato
- Sempre verificar docs/mcp-contracts.md antes de criar nova integração MCP
- Nunca criar secrets, credenciais ou tokens no código — sempre .env
- Nunca fazer chamadas de rede não documentadas no plano
- Perguntar antes de decisões arquiteturais não previstas na spec
- Preferir bibliotecas estabelecidas em vez de implementar do zero
- Ao terminar uma task, rodar lint (biome/ruff) e testes antes de commitar

### Worktree Workflow

Cada task deve ser executada em um worktree isolado:

```bash
# Criar worktree
git worktree add ../{projeto}-{feature}-{task} feature/{feature}/{task}

# Ao concluir task
git checkout feature/{feature}
git merge feature/{feature}/{task} --no-ff -m "task({numero}): {nome}"
git worktree remove ../{projeto}-{feature}-{task}
git branch -d feature/{feature}/{task}
```

### Segurança

Antes de marcar qualquer task como concluída:

- [ ] Inputs validados e sanitizados no servidor
- [ ] Autenticação verificada antes da lógica de negócio
- [ ] Queries parametrizadas — zero interpolação de string em SQL
- [ ] Nenhum dado sensível em logs ou respostas de erro
- [ ] Secrets em variáveis de ambiente — nenhum hardcoded
- [ ] Dependências auditadas (npm audit / pip-audit)

### Documentação

- Atualizar `docs/modules/{modulo}.md` ao modificar um módulo
- Atualizar `docs/mcp-contracts.md` se nova tool MCP criada
- Manter CHANGELOG.md com Conventional Commits

## Referências

- Convenções: `.specify/memory/constitution.md`
- Arquitetura: `docs/architecture.md`
- MCP contracts: `docs/mcp-contracts.md`
