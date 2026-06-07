---
name: write-integration-test
description: >
  기존 코드에 대한 통합/e2e 테스트를 신규 추가하거나 커버리지를 확장한다.
  "통합 테스트 추가/보강", "e2e 시나리오 작성", "이 플로우를 테스트로 묶어줘"를 언급하면 반드시 사용하라. app/ 전용.
  near-miss: 단일 함수의 사소한 단위 단언 한 줄 수정이면 트리거하지 말 것(직접 편집).
scope: app
---

# 통합/e2e 테스트 추가·확장

## 언제 쓰나 / 안 쓰나
- 트리거: 검증되지 않은 플로우에 통합 테스트 추가, 경계/에러 케이스 e2e 보강
- 비트리거(near-miss): 기존 단위 테스트 단언 한 줄 손보기 → 직접 수정

## 범위 제약
- 수정 가능: `app/` (테스트 디렉터리 위주)
- 절대 금지: 프로덕션 동작 변경(테스트만 추가), 다른 범위 수정

## 절차

### Step 1 — 대상 플로우 탐색
대상 코드의 진입점·의존성·기존 테스트 패턴을 읽어 어떤 경로가 비어있는지 식별.
- 검증: `./gradlew test --tests '*ExistingFlowTest'` (현 상태 확인)

### Step 2 — 테스트 작성
실제 협력 객체/컨테이너를 띄워 시나리오를 재현하는 통합 테스트 작성. 의미 있는 단언 포함.
- 검증: `./gradlew compileTestJava`

### Step 3 — 실행/안정화
- 검증: `./gradlew test --tests '*NewFlowIntegrationTest'`

### Step 4 — 완료 검증 (필수)
- [ ] `./gradlew test` 통과(플레이키 없음)
- [ ] 범위 밖 파일 수정 없음(프로덕션 코드 무변경)
- [ ] 추가한 케이스가 실제 경계/에러를 검증

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
