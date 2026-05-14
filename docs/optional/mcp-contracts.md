# MCP Contracts

> **Optional** — this file is only relevant if your project exposes tools to LLMs.
> If your project does not use MCP, ignore this file (or delete it).
>
> Central registry of all MCP servers and tools in the project.
> Update **before** implementing any new tool. See the `mcp-contract` skill.

---

## Registered Servers

| Server | Domain | File | Status |
|---|---|---|---|
| {name}-server | {domain} | mcp/servers/{name}-server.py | planned / active |

---

## {domain}

### {domain}_{verb}_{resource}

- **Description**: {what the tool does}
- **Input**: `{ param: type }`
- **Output**: `{ field: type }`
- **Errors**: `ERROR_CODE_1`, `ERROR_CODE_2`
- **Permission**: read-only / read-write / admin
- **Tenant Isolation**: {how the tenant_id is validated}

---

> Copy the block above for each new tool. Keep sorted by domain.
