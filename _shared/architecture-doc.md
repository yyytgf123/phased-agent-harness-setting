# Architecture Doc — 전체 구조 추적 (살아있는 스냅샷)

하네스 **전체 구조의 현재 상태**를 한 파일에 담는다. result_report가 "작업 단위 기록"이라면,
이건 "지금 구조가 어떻게 생겼나"를 보여주는 **단일 스냅샷**이다. 구조가 바뀔 때마다 갱신한다.

## 위치 / 파일
```
docs/architecture.md      # 단 하나. 항상 최신 상태만 유지(과거 이력 누적 안 함)
```
- result_report와의 차이: result_report는 작업마다 **새 파일**(이력), architecture.md는 **항상 1개**(현재 상태).
- 과거 변경 이력이 필요하면 git 히스토리로 본다. 이 파일에 변경 로그를 쌓지 않는다.

## 무엇을 담나 (섹션 고정)
```
# Architecture — <PROJECT_NAME>

> 최종 갱신: YYYY-MM-DD (작업: <한 줄>)

## Agents
| 에이전트 | 범위 | 타입 | 연결 스킬 |
|----------|------|------|-----------|
| backend-dev | app/ | general-purpose | add-rest-endpoint, write-integration-test |
| infra-dev   | infra/, monitoring/ | general-purpose | add-terraform-module |
| reviewer    | 전체 읽기 | Explore | — |

## Skills
| 스킬 | 소유 에이전트 | 범위 | 한 줄 설명 |
|------|---------------|------|-----------|
| add-rest-endpoint | backend-dev | app | 컨트롤러·서비스·DTO·테스트·OpenAPI 생성 |

## Orchestrator
- 실행 모드: <팀 | 서브>
- 패턴: <생성-검증 | 파이프라인 | ...>
- 데이터 경로: <_workspace/ 규약 한 줄>

## Hooks
| Hook | 시점 | 무엇을 강제 |
|------|------|-------------|
| safety   | PreToolUse | apply/migrate/secret 차단 |
| observe  | Pre/PostToolUse | 패턴 관찰 (Phase 7) |

## Data Flow
- 입력: docs/work_orders/ (작업지시서) → 에이전트
- 중간: _workspace/{phase}_{agent}_{artifact}
- 출력: 코드 + docs/result_report/
```

## 갱신 규칙 — **토큰 비용 최적화 (중요)**
구조가 바뀔 때마다 전체를 다시 쓰면 매번 파일 전체를 컨텍스트에 올렸다 다시 출력해야 해
토큰이 크게 든다. 아래로 비용을 줄인다.

1. **전체 재작성 금지 — 부분 편집만.**
   파일 전체를 읽어 통째로 다시 출력하지 말고, **바뀐 섹션의 해당 행(row)만**
   `str_replace`(또는 edit) 같은 부분 편집으로 고친다. 안 바뀐 섹션은 건드리지 않는다.
   - 예: 스킬 1개 추가 → `## Skills` 표에 행 1줄 append, 나머지 그대로.

2. **섹션 단위로 끊어 읽기.**
   갱신 전 파일 전체를 읽지 말고, 바꿀 섹션만 grep/부분 view로 확인한다.
   (`## Skills`만 볼 거면 그 블록만.)

3. **표(table)로 고정 — 산문 금지.**
   각 항목을 표의 한 행으로 둔다. 행 단위라 추가·수정·삭제가 1줄 편집으로 끝나고,
   diff도 작아 git·컨텍스트 모두 가볍다. 설명은 행당 한 줄(셀)로 제한.

4. **갱신 트리거를 좁힌다 (아무 때나 갱신 금지).**
   구조가 실제로 바뀐 Phase 종료 시에만 갱신한다:
   - Phase 3(에이전트 추가/범위 변경), Phase 4(스킬 추가/삭제),
     Phase 5(오케스트레이터 변경), Phase 7(Hook 추가·규칙 승격).
   - 코드만 고치고 구조가 그대로면 갱신하지 않는다. (result_report만 남긴다.)

5. **헤더 한 줄만 날짜 갱신.**
   `> 최종 갱신:` 줄 1개만 바꾼다. 본문에 변경 로그 문단을 새로 쌓지 않는다(2번 위반).

6. **상한 1화면.**
   architecture.md는 "지도"다. 표가 길어지면 상세는 해당 산출물 파일로 미루고
   여기엔 요약 행만 남긴다. (CLAUDE.md 60줄 원칙과 같은 사상.)

## 만들고 갱신하는 시점
- 최초 생성: **Phase 5 종료 시** (에이전트·스킬·오케스트레이터가 다 모인 시점).
- 이후 갱신: 위 트리거(4번) 발생 시 부분 편집.
- 민감정보(secret/키/경로) 기록 금지 (`safety-rules.md`).

> **층위 주의:** 이 파일은 키트의 *지침*이다. "구조 바뀌면 갱신"이 실사용에서 동작하려면
> Phase 3에서 이 갱신 규칙이 루트 `CLAUDE.md`의 `## Docs & Work Orders` 섹션에 박혀야 한다.
> 파일 자체(`docs/architecture.md`)는 Phase 5에서 최초 생성된다.
