# step 3 — 에이전트 생성 (카탈로그 기반, 많이)

> 도구+도메인에 맞는 에이전트를 **카탈로그에서 풍부하게** 골라 만든다.
> "선언한 도구 대비 너무 적다"를 여기서 푼다. 단, 작업 시엔 필요한 것만 활성화된다(온디맨드 스폰).

## 할 일 (대상 프로젝트 `.claude/agents/`에 생성)
1. `catalog/index.yaml`을 평가한다: 사용자 도구 목록 + 도메인 설명 텍스트를 스캔해
   `when_any`/`always`/`when_mixed` 조건에 **매칭되는 에이전트 블루프린트 전체**를 선택한다.
   - 매칭 근거(어떤 키워드로 뽑혔는지)를 사용자에게 표로 제시.
2. 선택된 각 블루프린트(`catalog/agents/<id>.md`)를 `templates/AGENT.md.tmpl` 형식으로
   `.claude/agents/<id>.md`에 구체화:
   - `<placeholder>`를 step0 확정 스택/버전으로 치환, 검증·테스트 명령은 `kb/tooling-matrix.md`로 실제 명령 치환.
   - 안전 참조는 루트 헌법 `claude.md`(`# CRITICAL — Safety`)를 가리키게 둔다(옛 rules/safety.md 아님).
   - 팀 모드면 `## 팀 통신 프로토콜` 섹션 포함, 서브/단독이면 생략(토큰 절약).
3. 설계 판단이 필요하면 `kb/agent-design-patterns.md`(실행모드·6패턴·4축)·`kb/agent-team-examples.md`,
   QA 포함 시 `kb/qa-agent-guide.md`를 참조.

## 로드 (이 step만)
- kb: `agent-design-patterns.md`, `agent-team-examples.md`, `qa-agent-guide.md`, `safety-rules.md`
- catalog: `index.yaml`, `agents/*`
- 템플릿: `AGENT.md.tmpl`

## 게이트
- 없는 레이어(예: infra 미선언)의 에이전트는 만들지 않는다.
- 혼합 레포는 app/infra 컨텍스트 분리 필수(backend-dev↔infra-dev 침범 차단).
- QA는 general-purpose 타입(Explore는 검증 스크립트 실행 불가).
- ◀승인 게이트: 선택된 에이전트 집합을 사용자가 확인해야 step4로.
