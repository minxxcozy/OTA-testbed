# OTA-testbed
> 컨테이너 이미지를 로컬에서 빌드하고 SBOM 및 취약점 분석을 수행한 후 실행·헬스체크·동적 테스트까지 자동으로 검증하는 로컬 검증 파이프라인

## ⚙️ Prerequisites
* Podman 또는 Docker (Ex. podman 명령 사용 기준)
* k3s 또는 로컬 Kubernetes 클러스터 (Ex. k3s, kind, minikube)
* Trivy 등 취약점 스캐너 (SBOM/취약점 스캔 스크립트에서 사용)

## ✅ Command
### 1️⃣ 이미지 빌드
```
# 스크립트 사용
scripts/build.sh

# 또는 수동 (podman 기준)
podman build -t localhost/ivi-theme:0.1 ./ota-asset
```
* 목적: OTA 에셋(또는 웹 UI)용 컨테이너 이미지 생성
* 결과: `localhost/ivi-theme:0.1` 태그의 이미지 생성


### 2️⃣ SBOM 생성 및 취약점 스캔
```
scripts/sbom.sh
```
* SBOM(Software Bill Of Materials) 생성 및 Trivy(또는 설정된 툴)로 취약점 스캔을 진행
* 산출물: `artifacts/sbom.json`, `artifacts/trivy.log` 등

### 3️⃣ 로컬 컨테이너 실행 및 헬스체크
```
scripts/k3s_deploy.sh
```
* 로컬 k3s/클러스터에 Deployment/Service 등을 배포하고 간단한 헬스체크를 수행
* 배포가 완료되면 서비스가 노출되는 포트 확인

### 4️⃣ 웹 페이지 확인
HTTP 응답 헤더 확인:
```
curl -I http://localhost:8080
```

WSL 환경에서 브라우저 열기:
```
wslview http://localhost:8080
```

Windows에서 브라우저 열기:
```
explorer.exe http://localhost:8080
```

### 5️⃣ 동적 테스트 실행
```
scripts/run_local_tests.sh
```
* 기본적인 엔드투엔드/동적 테스트(Ex. HTTP 기능 검사, API 시나리오, 프로세스 검사 등)를 실행
* 테스트의 로그 / 산출물은 `artifacts/` 아래 저장

### 6️⃣ 결과 파일 확인
Trivy 취약점 로그:
```
cat artifacts/trivy.log
```

SBOM 파일(JSON) 확인 (`jq`가 있으면 보기 편함):
```
cat artifacts/sbom.json | jq .
# 또는
less artifacts/sbom.json
```

프로세스 목록 (D7 테스트 결과):
```
cat artifacts/proc_list.log
```

## 💡 Tip
* `curl -I`에서 200 응답이 안 나오면 `kubectl get pods -A` / `kubectl logs <pod>`로 로그 확인
* `podman build` 실패 시 Dockerfile 경로(`./ota-asset`)와 권한(파일 소유/읽기) 확인
* `scripts/sbom.sh`가 실패하면 스캐너(`Trivy`)가 설치되어 있는지 확인
* WSL에서 포트가 동작하지 않으면 WSL 네트워크/방화벽, 포트 포워딩 설정 점검
