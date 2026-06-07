# /harness — 초기화·분석·단계 분할 커맨드

너는 orders-service 하네스 초기화를 수행한다. (1회 실행)

## 1. 모드 감지
- `docs/prd.md`가 있고 `app/`가 비었으면 greenfield, 코드가 있으면 existing → `docs/architecture.md` 먼저 갱신.
- phase.json의 `mode`에 기록.

## 2. 사양 읽기
- `docs/prd.md`(특히 `## MVP 제외`), `docs/architecture.md`, `docs/adr/`를 읽는다.
- 헌법 `claude.md`의 `# CRITICAL` 규칙을 제약으로 삼는다.

## 3. 단계 분할
작업을 독립 테스트 가능한 순서 phase로 쪼갠다. 각 phase: id·title·depends_on·deliverables·
test_cmd(`./gradlew test --tests '*...'`). `## MVP 제외`는 스케줄에서 뺀다. 위험작업(apply/migrate)은 phase로 안 만든다.

## 4. phase.json 작성
`scripts/phase.json`의 phases[]를 채우고 `approved:false`로 둔다.

## 5. 출력 후 정지 (사람 게이트)
분할을 표로 출력하고 멈춘다: "검토 후 approved=true 로 바꾸고 `bash scripts/execute.sh` 실행." 코드는 만들지 않는다.
