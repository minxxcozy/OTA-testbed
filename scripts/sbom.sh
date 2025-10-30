#!/usr/bin/env bash
set -euo pipefail
IMG=localhost/ivi-theme:0.1
mkdir -p artifacts

if command -v trivy >/dev/null 2>&1; then
  trivy image --severity HIGH,CRITICAL "$IMG" | tee artifacts/trivy.log
  trivy image --format cyclonedx --output artifacts/sbom.json "$IMG"
  echo "[OK] SBOM(CycloneDX) => artifacts/sbom.json"
  exit 0
fi

if command -v syft >/dev/null 2>&1; then
  syft packages "docker:$IMG" -o cyclonedx-json > artifacts/sbom.json
  echo "[OK] SBOM(CycloneDX) => artifacts/sbom.json"
  exit 0
fi

echo "Install trivy or syft first" >&2; exit 1
