---
summary: "CLI reference for `genesis daemon` (legacy alias for gateway service management)"
read_when:
  - You still use `genesis daemon ...` in scripts
  - You need service lifecycle commands (install/start/stop/restart/status)
title: "daemon"
---

# `genesis daemon`

Legacy alias for Gateway service management commands.

`genesis daemon ...` maps to the same service control surface as `genesis gateway ...` service commands.

## Usage

```bash
genesis daemon status
genesis daemon install
genesis daemon start
genesis daemon stop
genesis daemon restart
genesis daemon uninstall
```

## Subcommands

- `status`: show service install state and probe Gateway health
- `install`: install service (`launchd`/`systemd`/`schtasks`)
- `uninstall`: remove service
- `start`: start service
- `stop`: stop service
- `restart`: restart service

## Common options

- `status`: `--url`, `--token`, `--password`, `--timeout`, `--no-probe`, `--deep`, `--json`
- `install`: `--port`, `--runtime <node|bun>`, `--token`, `--force`, `--json`
- lifecycle (`uninstall|start|stop|restart`): `--json`

## Prefer

Use [`genesis gateway`](/cli/gateway) for current docs and examples.
