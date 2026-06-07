# _shared — 여러 Phase가 공유하는 규칙

특정 Phase에 속하지 않고 전 단계에서 참조하는 공통 자료.

| 파일 | 무엇을 담음 | 어디서 쓰나 |
|------|-------------|-------------|
| `design-principles.md` | 횡단 설계 원칙 (시스템 강제·도구 최소·컨텍스트 상한·Bug Log) | 전 Phase |
| `safety-rules.md` | 위험 명령 차단 + Hook 기반 시스템 강제 | Phase 2·3·4·6 |
| `result-report.md` | 작업 완료 시 `docs/result_report/`에 짧은 리포트 남기는 규칙 | 모든 작업·Phase 종료 시 |
| `architecture-doc.md` | 전체 구조 스냅샷(`docs/architecture.md`) 유지 + 토큰 절약 갱신 규칙 | Phase 5 생성, 이후 구조 변경 시 |
| `work-orders.md` | 작업참고서·작업지시서(`docs/work_orders/`) 참조 규칙 | 프롬프트에 지시서 참고 지시가 있을 때 |
| `metrics.md` | 토큰·성능 측정 프로토콜 (`tools/token-report.sh` 운영 규칙) | Phase 6 게이트·Phase 7 추세, 최적화 작업 시 |

## Phase 로드 맵 (각 단계가 읽을 파일 — 결정적 로딩)
각 phase는 아래 **딱 그 파일들만** 로드한다. 전체 _shared·templates를 매번 끌어오지 않는다(컨텍스트 절약).
(표 안 파일명은 약식 — 템플릿 열은 `.tmpl`, _shared 열은 `.md` 생략. 예: `design-principles` = `_shared/design-principles.md`.)

| Phase | 폴더 내 상세 | 템플릿 | _shared |
|-------|--------------|--------|---------|
| 0 setup | version-policy, tooling-matrix | reports/version-table | — |
| 1 discovery | discovery-checklist | reports/discovery | — |
| 2 architecture | agent-design-patterns | reports/architecture-design (+AGENT.md.tmpl 참조) | design-principles |
| 3 agents | team-examples, qa-agent-guide | AGENT, CLAUDE, rules-safety, settings.json, hooks/safety.sh | safety-rules, design-principles, work-orders, architecture-doc |
| 4 skills | skill-writing-guide | SKILL.md.tmpl | safety-rules |
| 5 orchestration | orchestrator-template | SKILL.md.tmpl, architecture.md | architecture-doc(스냅샷 생성) |
| 6 validation | skill-testing-guide | reports/validation | metrics(토큰 게이트) |
| 7 evolution | evolution-guide, observe-spec, instinct-format | hooks/observe.sh, settings.json, instincts.md | design-principles, metrics(추세) |
| 매 작업·단계 종료 | — | result-report.md | result-report |

> 지속 개선 루프(관찰→점수→승격→정리)는 정식 단계로 승격되어 `../phase/phase7_evolution/`에 있다.

> 도구→검증 명령 매핑(`tooling-matrix.md`)도 여러 Phase에서 쓰지만,
> 스택 확정과 함께 보는 게 자연스러워 `../phase/phase0_setup/`에 두었다.
