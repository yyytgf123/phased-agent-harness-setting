# Phase 3 — 에이전트 정의 생성 (Agents)

## 이 단계는 무엇을 하나
Phase 2 설계안을 실제 파일로 구축한다. **여기서 처음 산출물이 생성된다.**
- 각 에이전트 → `프로젝트/.claude/agents/{name}.md`
- 프로젝트 진입 맵 → 루트 `CLAUDE.md`

## 읽을 상세 (이 폴더)
| 파일 | 무엇을 담음 |
|------|-------------|
| `team-examples.md` | 개발/인프라 실전 팀 3종 — 어떤 에이전트 조합을 쓸지 참고 |
| `qa-agent-guide.md` | QA 포함 시 필독 — 경계면 교차비교 + 7개 버그 패턴 |

## 쓸 템플릿 (`../../templates/`)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `AGENT.md.tmpl` | `.claude/agents/{name}.md` (에이전트마다 하나씩) |
| `CLAUDE.md.tmpl` | 루트 `CLAUDE.md` (맵, 60줄 이하) |
| `rules-safety.md.tmpl` | `.claude/rules/safety.md` (안전 단일 소스) |
| `settings.json.tmpl` · `hooks/safety.sh.tmpl` | `.claude/settings.json` + `.claude/hooks/safety.sh` (차단 Hook) |

## 구축 절차
1. 상세 md(team-examples, qa-agent-guide)를 읽어 팀 구성을 확정한다.
2. `../../templates/AGENT.md.tmpl`을 떠서 에이전트마다 `.claude/agents/{name}.md` 생성.
   - 빌트인 타입이라도 정의 파일은 만든다. model 기본 opus.
   - 필수 섹션: 핵심역할/작업원칙/입출력/에러핸들링/협업. 팀 모드면 `## 팀 통신 프로토콜` 추가.
3. `../../templates/CLAUDE.md.tmpl`을 떠서 루트 `CLAUDE.md` 생성 (Phase 1 탐색 결과로 채움).
   - 템플릿의 `## Docs & Work Orders` 섹션을 그대로 둔다 — 작업지시서(`docs/work_orders/`) 참조와
     구조 스냅샷(`docs/architecture.md`) 갱신을 **에이전트 상시 규칙으로** 박는다.
     (상세 근거: `../../_shared/work-orders.md`, `../../_shared/architecture-doc.md`.)
   - `docs/work_orders/`(빈 폴더, 사용자가 지시서를 넣는 곳)와 `docs/result_report/`를 준비한다.
     `docs/architecture.md`는 여기서 만들지 않는다 — Phase 5 종료 시 최초 생성.
4. `../../_shared/safety-rules.md`를 프로젝트 **단일 소스** `.claude/rules/safety.md`로 1회 구축
   (전체 금지목록 + 표준 응답). CLAUDE.md `## NEVER`는 4줄 요약 + 이 파일 포인터만, 각 에이전트·스킬은
   표준 응답을 여기서 **참조**한다(전문 복붙 금지 — 트리거 시 로드되는 스킬 파일을 가볍게).
5. **시스템 강제 장치 구성** (텍스트 규칙보다 우선 — `../../_shared/design-principles.md`):
   - `settings.json.tmpl` → `.claude/settings.json`, `hooks/safety.sh.tmpl` → `.claude/hooks/safety.sh`로 떠서
     위험 명령을 Hook(PreToolUse)으로 차단.
   - **hook 경로는 상대경로 금지 — 반드시 `${CLAUDE_PROJECT_DIR}/.claude/hooks/...`.** (상대경로는
     서브에이전트/하위 디렉토리 실행 시 cwd가 어긋나 "No such file"로 깨진다.)
   - **생성한 hook에 실행권한 부여: `chmod +x .claude/hooks/safety.sh`.** (안 하면 런타임에 Permission denied.)
   - CLAUDE.md 템플릿의 `## Bug Log` 빈 섹션을 그대로 둔다 (이후 실수 누적용).

> 실사용 패턴을 자동 관찰·승격하는 지속 개선 루프는 Phase 7(Evolution)에서 구성한다.
> 여기서는 빈 Bug Log와 안전 Hook까지만 둔다.

## 표준 팀 (혼합 레포)
backend-dev(app/) / infra-dev(infra/,monitoring/) / reviewer(전체 읽기) / qa(선택)

## 입력 / 출력
- 입력: Phase 2 팀 설계안 + Phase 1 탐색 결과
- 출력: `.claude/agents/*.md` + 루트 `CLAUDE.md` → Phase 4로

## 게이트
- QA는 general-purpose 타입 (Explore는 검증 스크립트 실행 불가).
- 각 에이전트에 범위·금지 명령 명시 (apply/migrate/secret 차단).
