#!/usr/bin/env bash
set -euo pipefail
IMG=localhost/ivi-theme:0.1
TAR=artifacts/ivi-theme.tar
mkdir -p artifacts

# Podman 이미지를 tar 파일로 내보내기 
if [ ! -f "$TAR" ]; then
  echo "[+] Exporting Podman image to tar archive..."
  podman save "$IMG" -o "$TAR"
  echo "[OK] Image exported => $TAR"
fi

if command -v trivy >/dev/null 2>&1; then
  echo "[+] Running Trivy vulnerability scan..."
  trivy image --input "$TAR" --severity HIGH,CRITICAL | tee artifacts/trivy.log
  echo "[+] Generating SBOM..."
  trivy image --format cyclonedx --input "$TAR" --output artifacts/sbom.json
  echo "[OK] SBOM(CycloneDX) => artifacts/sbom.json"
  exit 0
fi

if command -v syft >/dev/null 2>&1; then
  echo "[+] Generating SBOM with Syft..."
  syft packages "docker-archive:$TAR" -o cyclonedx-json > artifacts/sbom.json
  echo "[OK] SBOM(CycloneDX) => artifacts/sbom.json"
  exit 0
fi

echo "Install trivy or syft first" >&2; exit 1
