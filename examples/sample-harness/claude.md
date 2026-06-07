# orders-service — Constitution (헌법)

<!-- 상시 로드. 프로젝트의 헌법(정책 단일 소스). 안전·TDD는 # CRITICAL. 옛 .claude/rules/safety.md 폐지. -->

# CRITICAL — Safety (절대 우선, 작업지시서보다도 위)
- 사람 승인 없이 실행 금지 — plan/dry-run까지만:
  `terraform apply|destroy`, `kubectl apply|delete`, `helm upgrade|install`, `flyway migrate`.
- 파괴적 명령 금지: `rm -rf`, `git push --force`/`-f`, `git reset --hard`.
- 시크릿 읽기·출력 금지: `*.env`, `*-prod.*`, `tfstate`, `kubeconfig`, `*.pem`.
- 담당 범위 밖 디렉터리 수정 금지(앱↔인프라 격리).
- 강제는 훅(`.claude/settings.json` → `safety.sh`). 이 텍스트는 정책.
- 표준 응답: "이 작업은 <명령>을 요구하는데 prod 영향이 있어 직접 실행하지 않습니다. <plan/dry-run 결과>를 검토 후 직접 실행하세요."

# CRITICAL — TDD (실패 테스트 뒤에만 구현)
- 대응 테스트(실패하는)가 없으면 구현 파일 작성 금지. `tdd-gate.sh`가 차단.
- 버그 수정은 재현 실패 테스트 → 픽스 → GREEN 순. 회귀 테스트로 남긴다.

## Map
- 앱: `app/` (`app/CLAUDE.md`) | 인프라: `infra/`,`monitoring/` (`infra/CLAUDE.md`)
- 에이전트: `.claude/agents/` | 스킬: `.claude/skills/` | 훅: `.claude/hooks/`
- 설계(SDD): `docs/prd.md`(+MVP 제외) · `docs/architecture.md` · `docs/adr/`
- 자율 실행: `scripts/execute.sh` + `scripts/phase.json` | 커맨드: `harness.md` · `review.md`
- 작업지시서: `docs/work_orders/` | 작업기록: `docs/result_report/`

## Build & Test
- 빌드: `./gradlew build` | 테스트: `./gradlew test` | 린트: `./gradlew spotlessCheck` / `tflint`
- 인프라 검증: `terraform validate && terraform plan`

## Technical Constraints
- DTO와 Entity 분리, Entity 직접 반환 금지. 결제는 정해진 PG 클라이언트 래퍼로만 호출.
- DB 변경은 Flyway forward-only 마이그레이션으로(기존 마이그레이션 수정 금지, 새 파일 추가).
- 인프라는 환경별(dev/stg/prod) 디렉터리 분리.

## Quality Guardrails (anti "AI slop")
- 죽은 코드·미사용 인자·TODO 스텁 금지. 커밋에 디버그 출력(System.out/console.log) 금지.
- 존재하지 않는 API 발명 금지 — 따라 한 기존 파일을 근거로 댄다. 범위 넘는 광범위 리팩터 금지.

## When stuck
1. 관련 테스트 먼저 읽기 → 2. 유사 파일 패턴 확인 → 3. 막히면 TODO 남기고 넘어가기(추측 강행 금지)

## Docs & Work Orders (상시 규칙)
- "작업지시서 참고" 지시가 오면 작업 전 `docs/work_orders/`를 먼저 읽고 맞춘다. 지목 파일만. 충돌 시 물어라.
  (# CRITICAL 규칙은 지시서보다 우선.)
- 구조가 바뀌면 `docs/architecture.md`를 부분 편집으로만 갱신.

## Bug Log
- [2026-06-07] reviewer 없이 결제 모듈 머지 → PG 연동 변경은 reviewer + security-reviewer 게이트 필수
