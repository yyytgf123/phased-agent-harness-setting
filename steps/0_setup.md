# step 0 — 스택·버전 확정 (Setup)

> 시작 전 사용자 스택과 버전을 못 박는다. 안 되면 뒤 step이 추측으로 흐른다.
> 사용자 입력은 루트 `ORCHESTRATOR.md`의 입력 칸으로 받는다.

## 할 일
1. `ORCHESTRATOR.md`에 사용자가 적은 "사용 도구 + 버전 + 도메인 설명 + repo_type"을 읽는다.
2. 버전이 비어 있으면 `kb/version-policy.md` 규칙대로 호환 버전을 **검색 후 선정**(현재 연도 기준, LTS 우선).
3. 도구 → 검증/테스트 명령 매핑은 `kb/tooling-matrix.md`로 확정한다(뒤 step의 test_cmd 근거).
4. 선정 결과를 `templates/reports/version-table.md.tmpl` 형식 **표로 출력**하고 사용자 승인을 받는다.

## 로드 (이 step만)
- kb: `version-policy.md`, `tooling-matrix.md`
- 템플릿: `reports/version-table.md.tmpl`

## 출력 / 게이트
- 출력: 확정 버전 표 + repo_type(app/infra/mixed) → step1로.
- ◀승인 게이트: 버전 표를 사용자가 승인하기 전엔 step1로 넘어가지 않는다.
- `version_policy: strict`인데 버전이 비었으면 진행 전 사용자에게 질문.
