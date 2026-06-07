# templates — 산출물 골격

Claude Code가 **복사·치환해서 프로젝트에 구축하는** 골격 모음.
`steps/`(지침)·`kb/`(지식)·`catalog/`(블루프린트)와 분리해 여기 모았다. 사용자가 채우는 파일이 아니다.
골격의 **단일 소스는 .tmpl**, steps/kb 문서는 규칙·근거만.

### 루트 산출물 골격
| 템플릿 | step | 구축 결과 |
|--------|------|-----------|
| `claude.md.tmpl` | 5 | 루트 `claude.md` (헌법, `# CRITICAL` 태그 — 안전·TDD 단일 소스) |
| `AGENT.md.tmpl` | 3 | `.claude/agents/{name}.md` (catalog/agents 블루프린트를 이 형식으로) |
| `SKILL.md.tmpl` | 4 | `.claude/skills/{name}/SKILL.md` (catalog/skills 블루프린트를 이 형식으로) |
| `settings.json.tmpl` | 5 | `.claude/settings.json` (safety+circuit-breaker+tdd-gate+observe hook) |
| `architecture.md.tmpl` | 5·운영 | `docs/architecture.md` 하단 "Harness 구조 스냅샷" 섹션 형식 |
| `result-report.md.tmpl` | 공통 | `docs/result_report/YYYYMMDD_HHMMSS.md` |
| `instincts.md.tmpl` | 운영 | `.claude/instincts/<hash>/instincts.md` |

### sdd/ — SDD 두뇌 골격 (step2)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `sdd/prd.md.tmpl` | `docs/prd.md` (요구사항 + `## MVP 제외`) |
| `sdd/architecture.md.tmpl` | `docs/architecture.md` (설계 의도 + 구조 스냅샷 섹션) |
| `sdd/adr.md.tmpl` | `docs/adr/<NNNN>-*.md` (결정 1개당 1파일) |
| `sdd/ui-guide.md.tmpl` | `docs/ui-guide.md` (UI 있는 프로젝트만) |

### engine/ — 자율 실행 엔진 골격 (step6)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `engine/execute.sh.tmpl` | `scripts/execute.sh` (phase 루프 + 테스트 게이트 + 서킷브레이커, bash+jq) |
| `engine/phase.json.tmpl` | `scripts/phase.json` (진행/상태, execute.sh만 작성) |
| `engine/harness.md.tmpl` | 루트 `harness.md` (초기화·단계 분할 커맨드) |
| `engine/review.md.tmpl` | 루트 `review.md` (검증·하네스 강화 커맨드) |

### hooks/ — 실행 스크립트 골격 (step5)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `hooks/safety.sh.tmpl` | `.claude/hooks/safety.sh` (위험명령 차단, exit 2) |
| `hooks/tdd-gate.sh.tmpl` | `.claude/hooks/tdd-gate.sh` (테스트 없는 구현 차단, exit 2) |
| `hooks/circuit-breaker.sh.tmpl` | `.claude/hooks/circuit-breaker.sh` (자율 루프 트립 시 정지, exit 2) |
| `hooks/observe.sh.tmpl` | `.claude/hooks/observe.sh` (비차단 관찰, exit 0) |

### reports/ — 단계 산출 리포트 골격
| 템플릿 | step | 구축 결과 |
|--------|------|-----------|
| `reports/version-table.md.tmpl` | 0 | 스택 확정 표 (승인용) |
| `reports/discovery.md.tmpl` | 1 | 탐색 보고서 |
| `reports/architecture-design.md.tmpl` | 3 | 팀 설계안 |
| `reports/validation.md.tmpl` | 7 | 검증 리포트 |

## 흐름
```
steps/(README) · kb/(지식) · catalog/(블루프린트)  ──읽고──▶  templates/**/*.tmpl  ──떠서──▶  프로젝트/{claude.md,docs/,scripts/,.claude/}
```
각 템플릿의 `<...>` 자리는 step 진행 중 스택·도메인·탐색 결과로 채운다.

## 런타임 토큰 규약 (생성물 최적화)
- **안전 정책 단일 소스 = 루트 `claude.md` `# CRITICAL — Safety`** (옛 `.claude/rules/safety.md` 폐지).
  에이전트·스킬은 헌법을 **참조**, 전문 복붙 금지.
- **선택 섹션은 조건부 생성.** 예: `AGENT.md.tmpl`의 `## 팀 통신 프로토콜`은 팀 모드일 때만.
- **catalog는 많이 방출하되 상시 비용은 lean** — 스킬 description만 상시, 본문은 트리거 시(Progressive Disclosure).
- **skill 본문 ≤500줄**, 도구별 상세는 `references/`로 내려 트리거 시 관련 파일만 로드.
