#!/usr/bin/env bash
set -euo pipefail
IMG=localhost/ivi-theme:0.1
podman build -t "$IMG" ./ota-asset
echo "[OK] built $IMG"
