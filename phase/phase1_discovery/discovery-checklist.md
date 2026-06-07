# Phase 1 Discovery — 탐색 항목 (개발/인프라)

> Phase 1에서 AI가 조사·보고만 하는 항목. 파일 생성 금지. 추측은 "추측" 표시.

## 1. 빌드/실행/검증 명령
- 빌드: (gradlew build / mvn package / npm run build / terraform init)
- 테스트: (gradlew test / pytest / jest / terraform validate)
- 린트·포맷: (spotless / checkstyle / ruff / eslint / tflint / kubeval / helm lint)
- 로컬 실행: (docker compose up / bootRun)

## 2. 디렉터리 지도 (2~3 depth)
- 앱 코드:
- 인프라 코드 (terraform/k8s/helm):
- 모니터링 (prometheus/grafana/alert):
- 테스트:
- CI/CD (.github/workflows, .gitlab-ci 등):

## 3. 기존 컨벤션 (코드에서 관찰된 것만)
- 앱: 패키지 구조, 네이밍, 예외 처리, DTO/Entity 분리
- 인프라: 모듈 구조, 네이밍, 환경 분리(dev/stg/prod)
- 테스트: 단위/통합 구분, 네이밍, 픽스처

## 4. 위험 지대
- DB 마이그레이션 파일:
- prod 상태/시크릿 (tfstate, *.env, secret, values-prod, kubeconfig, *.pem):
- 부작용 코드 (결제/배포/알림 외부 연동):

## 5. 기존 AI 설정
- .claude/ , CLAUDE.md , AGENTS.md , skills/ , agents/ 존재 여부 + 요약

## 6. 분류
"이 레포는 [앱 전용 / 인프라 전용 / 혼합]" 한 줄 결론.

---
## 보고를 어떻게 쓰나
- 1 → 스킬 검증 단계 + CLAUDE.md Build/Test 섹션
- 2 → CLAUDE.md "맵", 영역 분리 판단
- 3 → 스킬·에이전트 규칙
- 4 → safety-rules.md를 이 레포에 맞게 채움
- 5 → 있으면 덮어쓰지 말고 머지
- 6 → 팀 구성(혼합이면 backend-dev+infra-dev+reviewer) 결정
