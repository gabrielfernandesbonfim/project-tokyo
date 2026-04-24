---
name: mcp-contract
description: Use when the user wants to create, change, or review an MCP tool or MCP server in this project. Triggers on phrases like "new MCP tool", "add MCP server", "register MCP", "MCP contract", "expose tool to LLM". Enforces naming, registration-before-implementation, and the one-responsibility-per-tool rule.
---

# MCP Contract

MCP tools are the project's agent surface. Treat them as a public API: contract first, implementation second.

## Rule 0 — Register before implementing

Every new MCP tool is added to `docs/mcp-contracts.md` **before** any code is written. If the entry is not there yet, stop and add it.

## Decide whether MCP is the right shape

Use MCP when:

- A module exposes data or actions that an **LLM** or end user (via natural language) needs to reach.

Do **not** use MCP for:

- Ingestion pipelines, batch jobs, CRON tasks
- Auth internals (token minting, session rotation)
- Anything that is purely infrastructure-to-infrastructure

## Naming

Format: `{domain}_{verb}_{resource}`

Valid verbs: `get`, `list`, `create`, `update`, `delete`, `validate`.

Examples:

- `analytics_get_campaign_metrics`
- `tenant_list_active`
- `billing_create_invoice`

One domain per MCP server. Do not build a monolithic "everything server".

## Tool design rules

- One responsibility per tool — no "do many things" tools
- Read tools do not hold write credentials
- Tenant isolation validated **inside** the tool body, not upstream
- Every tool documents: description, input schema, output schema, errors, minimum permission

## Contract entry template

Copy this into `docs/mcp-contracts.md` before coding:

```markdown
### {domain}_{verb}_{resource}

- **Description**: {one sentence on what the tool does}
- **Input**: `{ param: type, ... }`
- **Output**: `{ field: type, ... }`
- **Errors**: `ERROR_CODE_1`, `ERROR_CODE_2`
- **Permission**: read-only / read-write / admin
- **Tenant Isolation**: {how tenant_id is validated}
```

Keep entries sorted by domain.

## Server registration

Add the server to the registry table at the top of `docs/mcp-contracts.md`:

```markdown
| {name}-server | {domain} | mcp/servers/{name}-server.py | planned / active |
```

Status starts as `planned` and flips to `active` only once the tool is implemented, tested, and reviewed.

## Reference

Full architectural rules in `.specify/memory/constitution.md` under "MCP Architecture Principles".
