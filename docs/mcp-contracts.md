# MCP Contracts

> Registro central de todos os MCP servers e tools do projeto.
> Atualizar **antes** de implementar qualquer nova tool.

---

## Servers Registrados

| Server | Domínio | Arquivo | Status |
|---|---|---|---|
| {nome}-server | {domínio} | mcp/servers/{nome}-server.py | planned / active |

---

## {domínio}

### {dominio}_{verbo}_{recurso}

- **Descrição**: {o que a tool faz}
- **Input**: `{ param: type }`
- **Output**: `{ campo: type }`
- **Erros**: `ERROR_CODE_1`, `ERROR_CODE_2`
- **Permissão**: read-only / read-write / admin
- **Tenant Isolation**: {como o tenant_id é validado}

---

> Copiar o bloco acima para cada nova tool. Manter ordenado por domínio.
