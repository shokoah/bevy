#!/usr/bin/env bash

set -euo pipefail

echo "bevy deployment"

# Check if root, exit if not
if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: This script must be run as root."
  exit 1
fi

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: Required command '$1' not found."
    exit 1
  fi
}

require_cmd docker
require_cmd sysctl
require_cmd modprobe

echo "Using compose command: $COMPOSE_CMD"

# Load modules
echo "Loading kernel modules..."

MODULES=(
  af_key
  xfrm_user
)

for module in "${MODULES[@]}"; do
  if lsmod | grep -q "^${module}"; then
    echo "✔ Module already loaded: $module"
  else
    echo "→ Loading module: $module"
    modprobe "$module"
    echo "Loaded: $module"
  fi
done

# Enable IPv4 Forwarding
echo "Enabling IP forwarding..."

SYSCTL_KEY="net.ipv4.ip_forward"
CURRENT_VALUE=$(sysctl -n $SYSCTL_KEY)

if [[ "$CURRENT_VALUE" -ne 1 ]]; then
  sysctl -w ${SYSCTL_KEY}=1
  echo "IP forwarding enabled"
else
  echo "IP forwarding already enabled"
fi

# Deploy
echo "Starting containers..."
$COMPOSE_CMD up -d --build

echo "=== Deployment successful ==="
echo "StrongMan UI: http://localhost:8080"
echo "strongSwan: listening on host (UDP 500 / 4500)"
