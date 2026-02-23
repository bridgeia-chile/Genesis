#!/usr/bin/env bash
set -euo pipefail

cd /repo

export genesis_STATE_DIR="/tmp/genesis-test"
export genesis_CONFIG_PATH="${genesis_STATE_DIR}/genesis.json"

echo "==> Build"
pnpm build

echo "==> Seed state"
mkdir -p "${genesis_STATE_DIR}/credentials"
mkdir -p "${genesis_STATE_DIR}/agents/main/sessions"
echo '{}' >"${genesis_CONFIG_PATH}"
echo 'creds' >"${genesis_STATE_DIR}/credentials/marker.txt"
echo 'session' >"${genesis_STATE_DIR}/agents/main/sessions/sessions.json"

echo "==> Reset (config+creds+sessions)"
pnpm genesis reset --scope config+creds+sessions --yes --non-interactive

test ! -f "${genesis_CONFIG_PATH}"
test ! -d "${genesis_STATE_DIR}/credentials"
test ! -d "${genesis_STATE_DIR}/agents/main/sessions"

echo "==> Recreate minimal config"
mkdir -p "${genesis_STATE_DIR}/credentials"
echo '{}' >"${genesis_CONFIG_PATH}"

echo "==> Uninstall (state only)"
pnpm genesis uninstall --state --yes --non-interactive

test ! -d "${genesis_STATE_DIR}"

echo "OK"
