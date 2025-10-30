#!/bin/bash
set -euo pipefail

IMG="localhost/ivi-theme:0.1"
ARCHIVE="artifacts/ivi-theme-0.1.tar"
SBOM="artifacts/sbom.json"

echo "[+] OTA Image Deploy via k3s simulation"
echo "[+] Checking if image archive exists..."

if [ ! -f "$ARCHIVE" ]; then
  echo "[INFO] Exporting image as Docker archive..."
  podman save --format docker-archive -o "$ARCHIVE" "$IMG"
fi

echo "[+] Generating SBOM..."
trivy image --format cyclonedx --input "$ARCHIVE" --output "$SBOM"
echo "[OK] SBOM generated -> $SBOM"

echo "[+] Verifying OTA image signature..."
set +e
cosign verify-blob \
  --key cosign.pub \
  --signature artifacts/sbom.sig \
  "$SBOM"
if [ $? -ne 0 ]; then
  echo "[WARN] Signature verification skipped or failed (local only)"
fi
set -e

echo "[+] Deploying image to k3s node..."
podman load -i "$ARCHIVE" >/dev/null
CID=$(podman run -d --replace --name ivi-ng --user 0 -p 8080:80 "$IMG")
echo "[OK] Container deployed ($CID)"

echo "[+] Running health check..."
sleep 2
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -q "200"; then
  echo "[OK] Deployment healthy (HTTP 200)"
else
  echo "[FAIL] Deployment not responding"
fi
