# templates — 산출물 골격

Claude Code가 **복사·치환해서 프로젝트에 구축하는** 골격 모음.
phase 폴더(지침·지식)와 분리해 여기 모았다. 사용자가 채우는 파일이 아니다.

모든 phase 산출물이 여기 골격을 갖는다(커버리지 일관). 골격의 **단일 소스는 .tmpl**, phase/_shared 문서는 규칙·근거만.

### 프로젝트 파일 골격 (루트)
| 템플릿 | Phase | 구축 결과 |
|--------|-------|-----------|
| `CLAUDE.md.tmpl` | 3 | 루트 `CLAUDE.md` (맵, 60줄 이하) |
| `AGENT.md.tmpl`  | 3 | `.claude/agents/{name}.md` |
| `SKILL.md.tmpl`  | 4·5 | `.claude/skills/{name}/SKILL.md` (오케스트레이터도 동일) |
| `rules-safety.md.tmpl` | 3 | `.claude/rules/safety.md` (안전 단일 소스) |
| `settings.json.tmpl` | 3·7 | `.claude/settings.json` (safety+observe hook) |
| `architecture.md.tmpl` | 5 | `docs/architecture.md` (구조 스냅샷) |
| `result-report.md.tmpl` | 공통 | `docs/result_report/YYYYMMDD_HHMMSS.md` |
| `instincts.md.tmpl` | 7 | `.claude/instincts/<hash>/instincts.md` |

### hooks/ (실행 스크립트 골격)
| 템플릿 | Phase | 구축 결과 |
|--------|-------|-----------|
| `hooks/safety.sh.tmpl` | 3 | `.claude/hooks/safety.sh` (차단형) |
| `hooks/observe.sh.tmpl` | 7 | `.claude/hooks/observe.sh` (비차단 관찰) |

### reports/ (단계 산출 리포트 골격)
| 템플릿 | Phase | 구축 결과 |
|--------|-------|-----------|
| `reports/version-table.md.tmpl` | 0 | 스택 확정 표 (승인용) |
| `reports/discovery.md.tmpl` | 1 | 탐색 보고서 |
| `reports/architecture-design.md.tmpl` | 2 | 팀 설계안 |
| `reports/validation.md.tmpl` | 6 | 검증 리포트 |

## 흐름
```
phase 폴더(README + 상세 md)  ──읽고──▶  templates/**/*.tmpl  ──떠서──▶  프로젝트/.claude/·docs/
        (지침·지식·규칙)                    (골격, 단일 소스)            (최종 산출물)
```

각 템플릿의 `<...>` 자리는 Claude Code가 Phase 진행 중 스택·도메인·탐색 결과로 채운다.

## 런타임 토큰 규약 (생성물 최적화)
- **`.claude/rules/safety.md`** = 프로젝트 단일 소스. 전체 금지목록 + 표준 응답을 한 곳에.
  CLAUDE.md `## NEVER`는 4줄 요약 + 포인터, 에이전트·스킬은 표준 응답을 **참조**(전문 복붙 금지).
- **선택 섹션은 조건부 생성.** 예: `AGENT.md.tmpl`의 `## 팀 통신 프로토콜`은 팀 모드일 때만 생성(서브/단독이면 생략).
- **CLAUDE.md는 상시 로드** → 60줄 유지. 초과분(Conventions·Bug Log)은 `.claude/rules/`로 분리.
- **skill 본문 ≤500줄**, 도구별 상세는 `references/`로 내려 트리거 시 관련 파일만 로드(Progressive Disclosure).
