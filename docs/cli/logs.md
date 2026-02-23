---
summary: "CLI reference for `genesis logs` (tail gateway logs via RPC)"
read_when:
  - You need to tail Gateway logs remotely (without SSH)
  - You want JSON log lines for tooling
title: "logs"
---

# `genesis logs`

Tail Gateway file logs over RPC (works in remote mode).

Related:

- Logging overview: [Logging](/logging)

## Examples

```bash
genesis logs
genesis logs --follow
genesis logs --json
genesis logs --limit 500
genesis logs --local-time
genesis logs --follow --local-time
```

Use `--local-time` to render timestamps in your local timezone.
