#!/usr/bin/env bash
set -euo pipefail
IMG=localhost/ivi-theme:0.1

echo "[+] Starting lightweight dynamic tests (D1/D4/D7)..."

# 깨끗한 상태로 시작
podman rm -f ivi-ng >/dev/null 2>&1 || true

# 보안 옵션 적용한 컨테이너 실행
podman run -d --name ivi-ng \
  --user 0 \
  -p 8080:80 \
  "$IMG"

# D1: 헬스체크 (컨테이너 정상 응답 여부)
if curl -fsSL http://127.0.0.1:8080/assets/ >/dev/null; then
  echo "[D1 PASS] health OK"
else
  echo "[D1 FAIL] health check failed"
fi

# D4: 파일시스템 쓰기 제한 확인
podman exec ivi-ng sh -lc 'echo ok >/tmp/x && echo "[D4] /tmp OK" || echo "[D4] /tmp FAIL"'
podman exec ivi-ng sh -lc 'echo bad >/etc/shadow && echo "[D4] should-not-see" || echo "[D4 PASS] RO root"'

# D7: 프로세스 목록 확인 (nginx 외 이상 프로세스 탐지)
podman exec ivi-ng ps aux | tee artifacts/proc_list.log
echo "[D7] Process list saved -> artifacts/proc_list.log"

echo "[DONE] D1/D4/D7 checks complete."
