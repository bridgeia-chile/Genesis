---
summary: "CLI reference for `genesis agents` (list/add/delete/set identity)"
read_when:
  - You want multiple isolated agents (workspaces + routing + auth)
title: "agents"
---

# `genesis agents`

Manage isolated agents (workspaces + auth + routing).

Related:

- Multi-agent routing: [Multi-Agent Routing](/concepts/multi-agent)
- Agent workspace: [Agent workspace](/concepts/agent-workspace)

## Examples

```bash
genesis agents list
genesis agents add work --workspace ~/.genesis/workspace-work
genesis agents set-identity --workspace ~/.genesis/workspace --from-identity
genesis agents set-identity --agent main --avatar avatars/genesis.png
genesis agents delete work
```

## Identity files

Each agent workspace can include an `IDENTITY.md` at the workspace root:

- Example path: `~/.genesis/workspace/IDENTITY.md`
- `set-identity --from-identity` reads from the workspace root (or an explicit `--identity-file`)

Avatar paths resolve relative to the workspace root.

## Set identity

`set-identity` writes fields into `agents.list[].identity`:

- `name`
- `theme`
- `emoji`
- `avatar` (workspace-relative path, http(s) URL, or data URI)

Load from `IDENTITY.md`:

```bash
genesis agents set-identity --workspace ~/.genesis/workspace --from-identity
```

Override fields explicitly:

```bash
genesis agents set-identity --agent main --name "genesis" --emoji "🦞" --avatar avatars/genesis.png
```

Config sample:

```json5
{
  agents: {
    list: [
      {
        id: "main",
        identity: {
          name: "genesis",
          theme: "space lobster",
          emoji: "🦞",
          avatar: "avatars/genesis.png",
        },
      },
    ],
  },
}
```
