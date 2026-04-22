# Architecture Decisions — {PROJECT NAME}

> Fill in during `/speckit.plan`. Every decision must be justified.
> This document is the reference for all technical choices in the project.

---

## 1. Frontend

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Framework | Next.js, Remix, Nuxt, SvelteKit | {choice} | {reason} |
| Styling | Tailwind, CSS Modules, Styled Components | {choice} | {reason} |
| State management | Zustand, Jotai, Redux Toolkit, Context | {choice} | {reason} |
| Forms | React Hook Form, Formik, native | {choice} | {reason} |

## 2. Backend

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Runtime/Framework | Next.js API Routes, FastAPI, Express, Hono | {choice} | {reason} |
| ORM/Query builder | Prisma, Drizzle, SQLAlchemy, Knex | {choice} | {reason} |
| Validation | Zod, Pydantic, Joi | {choice} | {reason} |

## 3. Database

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Primary database | Supabase (Postgres), Neon, Turso, PlanetScale | {choice} | {reason} |
| Warehouse/Analytics | BigQuery, ClickHouse, DuckDB/MotherDuck | {choice} | {reason} |
| Cache | Redis, Upstash, in-memory | {choice} | {reason} |

### Database comparison (reference)

**Managed Postgres**:
- **Supabase**: Auth + DB + Storage + Realtime integrated. Generous free tier (500MB). Best for MVPs that need fast auth. Cost scales with MAUs.
- **Neon**: Pure serverless Postgres, scale-to-zero. Cheaper at low-to-medium production usage. No built-in auth. Database branching for dev/preview environments.
- **Railway**: Simple Postgres, good DX. No major differentiators. Good for prototypes.

**Analytics/Warehouse**:
- **DuckDB/MotherDuck**: Local or serverless analytics. Very low cost. Ideal for data < 100GB. No infrastructure to manage.
- **ClickHouse Cloud**: High volume, fast queries. More complex to operate.
- **BigQuery**: Google ecosystem. Pay-per-query. Ideal if already on GCP.

## 4. Authentication

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Provider | Supabase Auth, Clerk, Auth.js, WorkOS | {choice} | {reason} |
| Strategy | JWT, Session, OAuth2 | {choice} | {reason} |
| Multi-tenancy | RLS, Schema per tenant, App-level | {choice} | {reason} |

### Auth comparison (reference)

- **Supabase Auth**: Free, integrated with Supabase DB. Native RLS. Best for projects already on Supabase.
- **Clerk**: Best DX, ready-made components, paid after 10k MAU. Good for SaaS.
- **Auth.js / NextAuth**: Open-source, self-hosted. More work, more control.
- **WorkOS**: B2B/SSO from day one. Enterprise-ready. Paid.

## 5. Deploy

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Frontend | Vercel, Netlify, Cloudflare Pages | {choice} | {reason} |
| Python backend | Cloud Run (GCP), Railway, Fly.io | {choice} | {reason} |
| CI/CD | GitHub Actions | GitHub Actions | Tokyo standard |

### Deploy comparison (reference)

**Frontend**:
- **Vercel**: Zero config for Next.js. Preview deploys. Generous free tier. Recommended default.
- **Netlify**: Similar to Vercel, better for static sites. Fewer features for Next.js.
- **Cloudflare Pages**: Cheaper at scale, edge-first. Inferior DX.

**Python backend**:
- **Cloud Run (GCP)**: Container-based, scale-to-zero, pay-per-use. Recommended if already on GCP.
- **Railway**: Simple, good DX. More expensive than Cloud Run in production.
- **Fly.io**: Edge deploy, good for global latency. More complex to configure.

## 6. MCP Surface

> Which modules expose tools for agents or users via natural language?

| Module | Has MCP? | Rationale |
|---|---|---|
| {module} | Yes/No | {reason} |

Rule: MCP only for modules where an LLM needs to access data or execute actions.
Never for: ingestion pipelines, auth internals, batch jobs.

## 7. Monitoring and Observability

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Error tracking | Sentry, BetterStack, LogRocket | {choice} | {reason} |
| Logging | Pino, Winston, structlog (Python) | {choice} | {reason} |
| Uptime | BetterStack, Checkly | {choice} | {reason} |

---

## Decisions Checklist

- [ ] Frontend framework defined
- [ ] Backend framework defined
- [ ] Primary database chosen
- [ ] Authentication defined
- [ ] Deploy target defined
- [ ] MCP surface mapped
- [ ] Monitoring planned
- [ ] All decisions justified
