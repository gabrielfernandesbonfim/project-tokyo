# Decisões de Arquitetura — {NOME DO PROJETO}

> Preencher durante `/speckit.plan`. Cada decisão deve ser justificada.
> Este documento é a referência para todas as escolhas técnicas do projeto.

---

## 1. Frontend

| Decisão | Opções Consideradas | Escolha | Justificativa |
|---|---|---|---|
| Framework | Next.js, Remix, Nuxt, SvelteKit | {escolha} | {motivo} |
| Styling | Tailwind, CSS Modules, Styled Components | {escolha} | {motivo} |
| State management | Zustand, Jotai, Redux Toolkit, Context | {escolha} | {motivo} |
| Forms | React Hook Form, Formik, native | {escolha} | {motivo} |

## 2. Backend

| Decisão | Opções Consideradas | Escolha | Justificativa |
|---|---|---|---|
| Runtime/Framework | Next.js API Routes, FastAPI, Express, Hono | {escolha} | {motivo} |
| ORM/Query builder | Prisma, Drizzle, SQLAlchemy, Knex | {escolha} | {motivo} |
| Validação | Zod, Pydantic, Joi | {escolha} | {motivo} |

## 3. Banco de Dados

| Decisão | Opções Consideradas | Escolha | Justificativa |
|---|---|---|---|
| Banco principal | Supabase (Postgres), Neon, Turso, PlanetScale | {escolha} | {motivo} |
| Warehouse/Analytics | BigQuery, ClickHouse, DuckDB/MotherDuck | {escolha} | {motivo} |
| Cache | Redis, Upstash, in-memory | {escolha} | {motivo} |

### Comparativo de bancos (referência)

**Postgres managed**:
- **Supabase**: Auth + DB + Storage + Realtime integrados. Free tier generoso (500MB). Melhor para MVPs que precisam de auth rápido. Custo sobe com MAUs.
- **Neon**: Postgres serverless puro, scale-to-zero. Mais barato em produção baixa-média. Sem auth built-in. Branching de banco para dev/preview.
- **Railway**: Postgres simples, bom DX. Sem diferenciais grandes. Bom para protótipos.

**Analytics/Warehouse**:
- **DuckDB/MotherDuck**: Analytics local ou serverless. Custo muito baixo. Ideal para dados < 100GB. Sem infraestrutura para gerenciar.
- **ClickHouse Cloud**: Alto volume, queries rápidas. Mais complexo de operar.
- **BigQuery**: Ecossistema Google. Pay-per-query. Ideal se já usa GCP para tudo.

## 4. Autenticação

| Decisão | Opções Consideradas | Escolha | Justificativa |
|---|---|---|---|
| Provider | Supabase Auth, Clerk, Auth.js, WorkOS | {escolha} | {motivo} |
| Estratégia | JWT, Session, OAuth2 | {escolha} | {motivo} |
| Multi-tenancy | RLS, Schema per tenant, App-level | {escolha} | {motivo} |

### Comparativo de auth (referência)

- **Supabase Auth**: Grátis, integrado com Supabase DB. RLS nativo. Bom para projetos já em Supabase.
- **Clerk**: Melhor DX, componentes prontos, pago após 10k MAU. Bom para SaaS.
- **Auth.js / NextAuth**: Open-source, self-hosted. Mais trabalho, mais controle.
- **WorkOS**: B2B/SSO desde o início. Enterprise-ready. Pago.

## 5. Deploy

| Decisão | Opções Consideradas | Escolha | Justificativa |
|---|---|---|---|
| Frontend | Vercel, Netlify, Cloudflare Pages | {escolha} | {motivo} |
| Backend Python | Cloud Run (GCP), Railway, Fly.io | {escolha} | {motivo} |
| CI/CD | GitHub Actions | GitHub Actions | Padrão Tokyo |

### Comparativo de deploy (referência)

**Frontend**:
- **Vercel**: Zero config para Next.js. Preview deploys. Free tier generoso. Padrão recomendado.
- **Netlify**: Similar ao Vercel, melhor para sites estáticos. Menos features para Next.js.
- **Cloudflare Pages**: Mais barato em escala, edge-first. DX inferior.

**Backend Python**:
- **Cloud Run (GCP)**: Container-based, scale-to-zero, pay-per-use. Recomendado se já usa GCP.
- **Railway**: Simples, bom DX. Mais caro que Cloud Run em produção.
- **Fly.io**: Edge deploy, bom para latência global. Mais complexo de configurar.

## 6. MCP Surface

> Quais módulos expõem tools para agentes ou usuários via linguagem natural?

| Módulo | Tem MCP? | Justificativa |
|---|---|---|
| {modulo} | Sim/Não | {motivo} |

Regra: MCP só para módulos onde uma LLM precisa acessar dados ou executar ações.
Nunca para: pipelines de ingestão, auth internals, jobs batch.

## 7. Monitoramento e Observabilidade

| Decisão | Opções Consideradas | Escolha | Justificativa |
|---|---|---|---|
| Error tracking | Sentry, BetterStack, LogRocket | {escolha} | {motivo} |
| Logging | Pino, Winston, structlog (Python) | {escolha} | {motivo} |
| Uptime | BetterStack, Checkly | {escolha} | {motivo} |

---

## Checklist de Decisões

- [ ] Frontend framework definido
- [ ] Backend framework definido
- [ ] Banco de dados principal escolhido
- [ ] Autenticação definida
- [ ] Deploy target definido
- [ ] MCP surface mapeada
- [ ] Monitoramento planejado
- [ ] Todas as decisões justificadas
