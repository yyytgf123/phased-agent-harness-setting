# Phase 6 — 검증 및 테스트 (Validation)

> 만든 하네스가 실제로 작동·효과 있는지 측정한다. 만들고 끝내면 그냥 문서다.

## 할 일 (`skill-testing-guide.md` 상세)
1. **구조 검증** — 에이전트 파일 위치, 스킬 frontmatter, 참조 일관성, commands 미생성.
2. **트리거 검증** — should-trigger 8~10 + should-NOT(near-miss) 8~10.
3. **범위 침범 테스트** — backend-dev에 infra 작업, infra-dev에 apply 시켜 막히는지.
4. **With-skill vs Without-skill 비교** — 같은 프롬프트 유/무 실행으로 부가가치 측정.
5. **드라이런** — Phase 순서, 데이터 경로 dead-link, 입출력 매칭, 폴백.
6. **토큰 게이트** — `tools/token-report.sh --gate <프로젝트>` 실행. CLAUDE.md ≤60줄·skill 본문 ≤500줄·
   안전 표준응답 단일소스 위반 시 **non-zero exit → 재작업**. 규칙은 `../../_shared/metrics.md`.
   결정적 강제를 원하면 생성 프로젝트의 `.claude/settings.json` **Stop hook**으로 이 명령을 건다
   (design-principles §1: 말로 말고 시스템으로).
7. 문제 발견 시 **일반화하여** 수정 후 재테스트.

## 이 폴더 파일
| 파일 | 용도 |
|------|------|
| `skill-testing-guide.md` | 6종 검증 방법론 + 효과 측정 |

## 쓸 템플릿 (`../../templates/`)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `reports/validation.md.tmpl` | 검증 리포트 (6검증 + 고칠 것 우선순위) |

## 입력 / 출력
- 입력: Phase 1~5 산출물 전체 (.claude/agents, .claude/skills, 오케스트레이터)
- 출력: 검증 리포트 + 고칠 것 우선순위

## 반복 루프
- 트리거 문제 → Phase 4(스킬 description) 수정
- 범위 침범 → Phase 3(에이전트 범위/금지) 수정
- 규칙 무시 → Phase 3(CLAUDE.md NEVER) 수정
- 고친 뒤 같은 대표 작업으로 재측정 (SGD 루프)

## 검증 이후 — Phase 7로
하네스는 한 번 검증으로 끝이 아니다. 실사용에서 나오는 패턴을 시스템이 흡수하게 하는
지속 개선 루프(관찰→점수→승격→정리)는 **Phase 7(Evolution)**에서 구축·운영한다.
> `../phase7_evolution/README.md`. 이게 앞 단계(1~6 구축)를 닫는 피드백 고리다.
