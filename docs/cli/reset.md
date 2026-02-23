---
summary: "CLI reference for `genesis reset` (reset local state/config)"
read_when:
  - You want to wipe local state while keeping the CLI installed
  - You want a dry-run of what would be removed
title: "reset"
---

# `genesis reset`

Reset local config/state (keeps the CLI installed).

```bash
genesis reset
genesis reset --dry-run
genesis reset --scope config+creds+sessions --yes --non-interactive
```
