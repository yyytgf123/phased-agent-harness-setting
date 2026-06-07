# /review — 검증·하네스 강화 커맨드

orders-service 산출물을 검증하고 하네스를 강화한다.

## 1. 산출물 검증
- `scripts/phase.json`의 `done` phase마다 deliverables 존재 확인 + `test_cmd` 재실행(회귀).
- `failed`/`blocked` phase 원인 요약.

## 2. 경계면 교차 QA (`kb/qa-agent-guide.md` 7패턴)
- API ↔ DTO, app env ↔ k8s/helm config, terraform output ↔ app config, Flyway migration ↔ Entity.
- `cross-boundary-check` 스킬 / `qa` 에이전트로 교차 검증.

## 3. 헌법 준수 스캔 (anti "AI slop")
- 죽은 코드, 디버그 출력(System.out), 범위 초과, 없는 API 발명, 테스트 누락(# CRITICAL — TDD), 안전 위반.

## 4. 하네스 강화 (코드 말고 하네스를 깎는다)
반복 실패·불만 패턴 → 구체 보강(사람 승인 후 적용):
- 결정적 차단 → `.claude/hooks/`(safety/tdd-gate). 행동 규칙 → `claude.md` Guardrails/Bug Log.
- 트리거 오발 → 스킬 description 강화. 반복 워크플로 → 새 스킬. 승격은 `kb/evolution.md` 루프로.

## 5. 리포트
- `docs/result_report/YYYYMMDD_HHMMSS.md`에 검증 결과 + 적용한 강화를 짧게(`kb/result-report.md` 형식).
