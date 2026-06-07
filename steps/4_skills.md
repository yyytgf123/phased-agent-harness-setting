# step 4 — 스킬 생성 (카탈로그 기반, 많이) + 오케스트레이터

> 에이전트가 쓸 "어떻게"(워크플로 절차)를 카탈로그에서 풍부하게 만든다.
> 많이 만들되, 상시 비용은 description만 — 본문은 트리거 시 로드(Progressive Disclosure).

## 할 일 (대상 프로젝트 `.claude/skills/`에 생성)
1. `catalog/index.yaml`의 `skills` 규칙을 평가해 **매칭되는 스킬 블루프린트 전체**를 선택한다.
   - 매칭 근거를 표로 제시.
2. 각 블루프린트(`catalog/skills/<id>.md`)를 `templates/SKILL.md.tmpl` 형식으로
   `.claude/skills/<id>/SKILL.md`에 구체화(**한 번에 1개씩**):
   - 검증·테스트 명령을 `kb/tooling-matrix.md`로 실제 스택 명령 치환.
   - description은 pushy + near-miss 구분 유지. 본문 500줄 이내, 도구별 상세는 `references/`로.
   - **TDD**: 구현 스킬은 "실패 테스트 먼저"를 절차에 명시(헌법 `# CRITICAL — TDD`).
   - 안전 참조는 루트 `claude.md` `# CRITICAL — Safety`로.
   - 앱 스킬과 인프라 스킬을 한 파일에 섞지 않는다.
3. **오케스트레이터 스킬** 1개 생성(`.claude/skills/<orchestrator>/SKILL.md`):
   `kb/orchestrator-patterns.md`로 모드별 패턴·데이터 전달·에러 전략을 정한다.
   필요한 에이전트만 온디맨드 스폰하는 흐름을 명시(전부 동시 로드 금지).

## 로드 (이 step만)
- kb: `skill-writing-guide.md`, `orchestrator-patterns.md`, `safety-rules.md`, `tooling-matrix.md`
- catalog: `index.yaml`, `skills/*`
- 템플릿: `SKILL.md.tmpl`

## 게이트
- 앱/인프라 스킬 혼합 금지. 위험 작업은 plan/dry-run까지만.
- 마지막 단계는 항상 "완료 검증"(무엇 실행→무엇 확인하면 done).
- ◀승인 게이트: 선택된 스킬 집합 + 오케스트레이터를 사용자가 확인해야 step5로.
