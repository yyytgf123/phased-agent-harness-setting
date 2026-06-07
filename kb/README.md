# kb — 지식베이스 (생성 전 단계가 참조하는 공통 자료)

특정 step에 속하지 않고 여러 step이 참조하는 횡단 지식. (옛 `_shared/` + `phase/*` 가이드 통합.)
각 step은 아래 **딱 필요한 파일만** 로드한다(컨텍스트 절약).

| 파일 | 무엇을 담음 |
|------|-------------|
| `design-principles.md` | 횡단 설계 원칙 (시스템 강제·도구 최소·컨텍스트 상한·Bug Log·Progressive Disclosure) |
| `safety-rules.md` | 위험 명령 차단 + 블랙리스트 + TDD 게이트 + Hook 기반 강제 |
| `tooling-matrix.md` | 도구 → 검증/테스트 명령 매핑 (스택별 test_cmd 근거) |
| `version-policy.md` | 버전 미기재 시 호환 버전 검색·선정 규칙 |
| `discovery-checklist.md` | 기존 레포 분석 6항목 |
| `agent-design-patterns.md` | 실행 모드, 6패턴, 4축 분리 기준 |
| `agent-team-examples.md` | 개발/인프라 실전 팀 3종 |
| `qa-agent-guide.md` | QA 경계면 교차비교 + 7개 버그 패턴 |
| `skill-writing-guide.md` | pushy description, Why, Progressive Disclosure, 본문 500줄 |
| `orchestrator-patterns.md` | 오케스트레이션 모드별 패턴, 데이터 전달, 에러 전략 |
| `skill-testing-guide.md` | 6종 검증 방법론 + 효과 측정 |
| `evolution.md` | 자체 학습 루프(관찰→축적→승격→정리) + observe/instinct 포맷 |
| `architecture-doc.md` | 구조 스냅샷(`docs/architecture.md`) 유지·갱신 규칙 |
| `work-orders.md` | 작업지시서(`docs/work_orders/`) 참조 규칙 |
| `result-report.md` | 작업 종료 시 짧은 리포트(`docs/result_report/`) 규칙 |
| `metrics.md` | 토큰·성능 측정 프로토콜 (`tools/token-report.sh`) |

## step 로드 맵 (각 step이 읽을 kb·템플릿 — 결정적 로딩)

| step | kb | 템플릿 |
|------|------|--------|
| 0 setup | version-policy, tooling-matrix | reports/version-table |
| 1 analyze | discovery-checklist, design-principles | reports/discovery |
| 2 sdd | design-principles | sdd/{prd,architecture,adr,ui-guide} |
| 3 agents | agent-design-patterns, agent-team-examples, qa-agent-guide, safety-rules | AGENT, (catalog/agents) |
| 4 skills | skill-writing-guide, orchestrator-patterns, safety-rules, tooling-matrix | SKILL, (catalog/skills) |
| 5 constitution | safety-rules, design-principles, work-orders, architecture-doc | claude.md, settings.json, hooks/* |
| 6 engine | (엔진 동작은 engine 템플릿 자체에) | engine/{execute.sh,phase.json,harness.md,review.md} |
| 7 validate | skill-testing-guide, metrics | reports/validation |
| 상시(산출물 운영) | evolution | engine/review.md, hooks/observe.sh, instincts.md |
| 매 작업 종료 | result-report | result-report.md |
