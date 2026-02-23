---
summary: "CLI reference for `genesis voicecall` (voice-call plugin command surface)"
read_when:
  - You use the voice-call plugin and want the CLI entry points
  - You want quick examples for `voicecall call|continue|status|tail|expose`
title: "voicecall"
---

# `genesis voicecall`

`voicecall` is a plugin-provided command. It only appears if the voice-call plugin is installed and enabled.

Primary doc:

- Voice-call plugin: [Voice Call](/plugins/voice-call)

## Common commands

```bash
genesis voicecall status --call-id <id>
genesis voicecall call --to "+15555550123" --message "Hello" --mode notify
genesis voicecall continue --call-id <id> --message "Any questions?"
genesis voicecall end --call-id <id>
```

## Exposing webhooks (Tailscale)

```bash
genesis voicecall expose --mode serve
genesis voicecall expose --mode funnel
genesis voicecall expose --mode off
```

Security note: only expose the webhook endpoint to networks you trust. Prefer Tailscale Serve over Funnel when possible.
