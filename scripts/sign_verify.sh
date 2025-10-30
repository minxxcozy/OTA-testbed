#!/usr/bin/env bash
set -euo pipefail
IMG=localhost/ivi-theme:0.1
TAR=artifacts/ivi-theme-0.1.oci.tar

mkdir -p artifacts

# 1) Podman 이미지를 OCI 아카이브로 내보내기
podman save --format oci-archive -o "$TAR" "$IMG"
echo "[OK] exported OCI archive => $TAR"

# 2) k3s(containerd)로 가져오기
sudo k3s ctr images import "$TAR"
echo "[OK] imported into k3s containerd"

# 3) 매니페스트 적용
kubectl apply -n ota-demo -f k8s/deployment.yaml
kubectl apply -n ota-demo -f k8s/service.yaml

# 4) 확인
kubectl -n ota-demo rollout status deploy/ivi-theme
kubectl -n ota-demo get pods -o wide
kubectl -n ota-demo get svc ivi-theme
echo "[DONE] k3s deploy"
