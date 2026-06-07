# steps — 생성 흐름 (지금처럼 step별 진행)

키트가 하네스를 **찍어내는** 순서. 번호 = 실행 순서. **매 step 끝에 멈추고 사람 승인**을 받는다
(현행의 가이드된 다단계 방식 유지). 막히면 해당 `steps/N_*.md`를 직접 연다.

> 주의: 이 step들은 키트의 **생성 과정**이다(자율 아님, 사람 게이트). 산출물에 들어가는
> 자율 엔진 `scripts/execute.sh`는 step6에서 *방출*되며, 가동 단계에서만 자율로 돈다.

| step | 파일 | 한 일 | 산출물 | 게이트 |
|------|------|-------|--------|--------|
| 0 | `0_setup.md` | 스택·버전 확정 | 버전 표 | 버전 승인 |
| 1 | `1_analyze.md` | greenfield/existing + discovery | 탐색 보고 | 분석 승인 |
| 2 | `2_sdd.md` | SDD 두뇌 | `docs/{prd,architecture,adr,ui-guide}` | PRD/SDD 승인 |
| 3 | `3_agents.md` | 카탈로그서 다수 에이전트 | `.claude/agents/*` | 에이전트 집합 |
| 4 | `4_skills.md` | 카탈로그서 다수 스킬 + 오케스트레이터 | `.claude/skills/*` | 스킬 집합 |
| 5 | `5_constitution.md` | 헌법 + 가드레일 | `claude.md`, `.claude/{settings.json,hooks}` | — |
| 6 | `6_engine.md` | 자율 실행 엔진 | `scripts/*`, `harness.md`, `review.md` | — |
| 7 | `7_validate.md` | 검증·테스트 | 검증 리포트 | 가동 준비 |

공통:
- 각 step은 `kb/README.md`의 "step 로드 맵"에 적힌 파일만 로드(컨텍스트 절약).
- 매 step 종료 시 `kb/result-report.md` 규칙대로 `docs/result_report/`에 짧은 리포트.
- 산출물 가동·지속 개선은 `kb/evolution.md`.
