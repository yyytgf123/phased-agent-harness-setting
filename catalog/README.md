# catalog — 도구·도메인 → agent/skill 블루프린트 카탈로그

"선언한 도구 대비 agent/skill이 너무 적다"를 푸는 곳. 후보 블루프린트를 **풍부하게** 두고,
생성 시 사용자의 도구+도메인에 맞는 것만 골라 `.claude/`에 방출한다. 작업 시엔 그중에서도
**필요한 것만 활성화**된다(아래 "상황별 활성화").

## 구성
```
catalog/
├── index.yaml      # tool/keyword → blueprint id 선택 규칙
├── agents/<id>.md  # 후보 에이전트 블루프린트 (frontmatter + 정의)
└── skills/<id>.md  # 후보 스킬 블루프린트 (= SKILL.md 본문, 생성 시 skills/<id>/SKILL.md로)
```

## 선택 규칙 (`index.yaml`)
각 블루프린트에 발동 조건을 단다:
- `when_any: [키워드…]` — 도구 목록 또는 도메인 설명에 키워드가 하나라도 있으면 선택.
- `always: true` — 항상 선택(예: reviewer).
- `when_mixed: true` — repo_type이 mixed(app+infra)일 때만.

step3(agents)·step4(skills)가 `index.yaml`을 평가해 **매칭된 전체 집합**을 방출한다.
도구가 많을수록 더 많은 agent/skill이 생긴다 → "너무 적다" 해결.

## 상황별 활성화 (많이 만들되, 다 쓰진 않는다)
방출량이 늘어도 상시 비용은 늘지 않게:
- **스킬**: description만 상시 로드, 본문은 트리거 시(Progressive Disclosure). 11개여도 상시 비용은 description 11줄.
- **에이전트**: 오케스트레이터가 작업에 필요한 에이전트만 온디맨드 스폰. 전부 동시 로드 아님.
- `tools/token-report.sh --gate`로 상시 비용 회귀를 막는다.

## 블루프린트 → 산출물 변환 (생성 step이 하는 일)
1. frontmatter의 `<placeholder>`를 step0 확정 스택/버전으로 치환.
2. 검증·테스트 명령을 `kb/tooling-matrix.md`로 실제 스택 명령으로 치환.
3. 안전 참조는 산출물 헌법 `claude.md`를 가리키게 둔다(옛 `.claude/rules/safety.md` 아님).
4. agent → `.claude/agents/<id>.md`, skill → `.claude/skills/<id>/SKILL.md`.
