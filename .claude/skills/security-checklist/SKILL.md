---
name: security-checklist
description: Use before marking any task as complete, before opening a PR, or whenever the user says "ready to commit", "finish task", "close task", "open PR", or asks for a security review of pending changes. Enforces the non-negotiable security gates defined in the constitution.
---

# Security Checklist

Run this **before** marking a task as complete. A task that fails any item is not done.

## Gate 1 — Input & data handling

- [ ] All user input is validated and sanitized **on the server** (client validation is UX, not security)
- [ ] SQL uses parameterized queries or an ORM — **zero string interpolation**
- [ ] No PII or sensitive data in logs or error responses
- [ ] Authentication is verified **before** any business logic runs

## Gate 2 — Secrets & configuration

- [ ] No secrets, tokens, or credentials in code or committed files
- [ ] Every new key is in `.env.example` (no value) and documented
- [ ] Production values are in the secret store (GitHub Secrets, provider vault) — not in source
- [ ] `gitleaks detect` passes locally

## Gate 3 — Multi-tenancy (when applicable)

- [ ] `tenant_id` validated on the server — never trusted from the client
- [ ] Row-level security active on every multi-tenant table touched
- [ ] Cross-tenant access impossible by construction (not by convention)
- [ ] Logs segregated by tenant

## Gate 4 — Dependencies & transport

- [ ] New dependencies audited (`npm audit` / `pip-audit`) — zero high/critical
- [ ] HTTPS enforced in all environments
- [ ] Security headers set where relevant (CSP, HSTS, X-Frame-Options)
- [ ] CORS restricted to explicit origins

## Gate 5 — MCP tools (when the task touches MCP)

- [ ] Tool registered in `docs/mcp-contracts.md` before implementation (see `mcp-contract` skill)
- [ ] Read tools do not hold write credentials
- [ ] Tenant isolation validated inside the tool body
- [ ] Minimum required permission documented

## If any gate fails

Do not mark the task complete. Either fix the issue or, if the fix is out of scope, open a follow-up issue referencing the failing gate and block the PR until it is resolved.

## Reference

Full rules in `.specify/memory/constitution.md` under "Security Principles". This checklist is the operational form — the constitution is the source of truth.
