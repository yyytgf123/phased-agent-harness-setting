# _shared — 여러 Phase가 공유하는 규칙

특정 Phase에 속하지 않고 전 단계에서 참조하는 공통 자료.

| 파일 | 무엇을 담음 | 어디서 쓰나 |
|------|-------------|-------------|
| `design-principles.md` | 횡단 설계 원칙 (시스템 강제·도구 최소·컨텍스트 상한·Bug Log) | 전 Phase |
| `safety-rules.md` | 위험 명령 차단 + Hook 기반 시스템 강제 | Phase 2·3·4·6 |
| `result-report.md` | 작업 완료 시 `docs/result_report/`에 짧은 리포트 남기는 규칙 | 모든 작업·Phase 종료 시 |
| `architecture-doc.md` | 전체 구조 스냅샷(`docs/architecture.md`) 유지 + 토큰 절약 갱신 규칙 | Phase 5 생성, 이후 구조 변경 시 |
| `work-orders.md` | 작업참고서·작업지시서(`docs/work_orders/`) 참조 규칙 | 프롬프트에 지시서 참고 지시가 있을 때 |

> 지속 개선 루프(관찰→점수→승격→정리)는 정식 단계로 승격되어 `../phase/phase7_evolution/`에 있다.

> 도구→검증 명령 매핑(`tooling-matrix.md`)도 여러 Phase에서 쓰지만,
> 스택 확정과 함께 보는 게 자연스러워 `../phase/phase0_setup/`에 두었다.
