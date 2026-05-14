# Architecture Decisions — {PROJECT NAME}

> Fill in during `/speckit.plan`. Every decision must be justified.
> This document is the reference for all technical choices in the project.
>
> Sections marked "(if applicable)" are conditional — delete or mark `N/A` if irrelevant.

---

## 1. Project Type

| Field | Value |
|---|---|
| Type | {web app / CLI tool / library / data pipeline / mobile / desktop / service / game / other} |
| Distribution | {npm package / container image / binary / static site / app store / internal service} |
| Primary users | {end users / developers / agents / internal team} |

## 2. Runtime & Language

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Language | {...} | {choice} | {reason} |
| Runtime / Engine | {...} | {choice} | {reason} |
| Package manager | {...} | {choice} | {reason} |
| Build tool (if applicable) | {...} | {choice} | {reason} |

## 3. Storage (if applicable)

> Skip if the project has no persistent state.

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Primary storage | {sqlite / postgres / files / object store / in-memory / none} | {choice} | {reason} |
| Cache | {Redis / in-process / N/A} | {choice} | {reason} |
| Analytics / Warehouse | {BigQuery / ClickHouse / DuckDB / N/A} | {choice} | {reason} |

## 4. Interface(s)

What this project exposes to the outside world.

| Surface | Tech / Framework | Rationale |
|---|---|---|
| {HTTP API / CLI / Library API / GUI / MCP / SDK} | {choice} | {reason} |

## 5. Authentication & Authorization (if applicable)

> Skip if the project has no users or no security boundary.

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Provider | {...} | {choice} | {reason} |
| Strategy | {JWT / Session / OAuth2 / API key / N/A} | {choice} | {reason} |
| Multi-tenancy | {N/A / RLS / schema-per-tenant / app-level} | {choice} | {reason} |

## 6. External Integrations

Third-party APIs, services, queues, providers.

| Integration | Purpose | Auth model | Rationale |
|---|---|---|---|

## 7. Deploy / Distribution

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Target | {...} | {choice} | {reason} |
| CI/CD | GitHub Actions | GitHub Actions | Tokyo standard |
| Release strategy | {tags / continuous / manual} | {choice} | {reason} |

## 8. Observability

| Decision | Options Considered | Choice | Rationale |
|---|---|---|---|
| Error tracking | {Sentry / BetterStack / N/A} | {choice} | {reason} |
| Logging | {Pino / Winston / structlog / stdlib / N/A} | {choice} | {reason} |
| Metrics / Uptime | {BetterStack / Checkly / Prometheus / N/A} | {choice} | {reason} |

## 9. MCP Surface (optional)

> Skip entirely if the project does not expose tools to LLMs.

Which modules expose tools for agents or users via natural language?

| Module | Has MCP? | Rationale |
|---|---|---|

Rule: MCP only when an LLM needs to access data or execute actions. Never for ingestion pipelines, auth internals, or batch jobs.

Register every tool in `docs/optional/mcp-contracts.md` **before** implementing it. See the `mcp-contract` skill.

---

## Decisions Checklist

- [ ] Project type defined
- [ ] Runtime and language chosen
- [ ] Storage decided (or marked N/A)
- [ ] Interface(s) declared
- [ ] Auth decided (or marked N/A)
- [ ] External integrations mapped
- [ ] Deploy target defined
- [ ] Observability planned
- [ ] MCP surface mapped (or marked N/A)
- [ ] All decisions justified
- [ ] `CLAUDE.md` → `Implementation Directories` filled
- [ ] `.claude/context/state.json` → `implementation_dirs` mirrored

---

## Appendix — Stack reference (delete what you don't use)

### Web frontend

- **Next.js**: full-stack React, SSR + ISR, Vercel-first. Default for web apps with no exotic requirements.
- **Remix**: web-standards-first, good for forms and progressive enhancement.
- **SvelteKit / Nuxt**: alternatives if you prefer Svelte / Vue.

### Web backend

- **Next.js API Routes**: fast for monolithic Next.js apps.
- **FastAPI**: typed Python, good for AI/data-heavy work.
- **Express / Hono**: minimal, flexible.

### Databases

- **Supabase**: Auth + Postgres + Storage + Realtime. Generous free tier. Cost scales with MAUs.
- **Neon**: serverless Postgres, scale-to-zero, branching for dev/preview.
- **DuckDB / MotherDuck**: analytics < 100GB, very low cost.
- **ClickHouse Cloud**: high-volume analytics.

### Auth providers

- **Supabase Auth**: integrated with Supabase DB and RLS.
- **Clerk**: best DX, paid above 10k MAU. Good for SaaS.
- **Auth.js**: self-hosted, more control.
- **WorkOS**: B2B SSO from day one.

### Deploy targets

- **Vercel**: zero-config for Next.js. Preview deploys.
- **Cloudflare Pages / Workers**: edge-first, cheaper at scale.
- **Cloud Run (GCP)**: container, scale-to-zero, pay-per-use.
- **Railway / Fly.io**: simple managed runtimes.
