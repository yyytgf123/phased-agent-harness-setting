---
name: add-rest-endpoint
description: >
  신규 REST 엔드포인트 추가 시 컨트롤러·서비스·DTO·테스트·OpenAPI를 함께 생성/갱신한다.
  새 API/라우트/엔드포인트 추가를 언급하면 반드시 사용. app/ 범위 전용.
  기존 엔드포인트 단순 수정만이면 트리거하지 않음.
scope: app
---

# 신규 REST 엔드포인트 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 API 경로 추가, 새 리소스 CRUD
- 비트리거(near-miss): 기존 엔드포인트 로직만 수정 → 일반 수정으로

## 범위 제약
- 수정 가능: `app/` 만
- 절대 금지: 다른 범위(`infra/` 등) 수정

## 절차

### Step 1 — 탐색
유사 컨트롤러 패턴 확인.
- 검증: `./gradlew compileJava`

### Step 2 — 구현
컨트롤러·서비스·DTO 생성, 레포 기존 패턴 모방.
- 검증: `./gradlew compileJava`

### Step 3 — 테스트/문서
통합 테스트 + OpenAPI 갱신.
- 검증: `./gradlew test --tests '*OrderControllerTest'`

### Step 4 — 완료 검증 (필수)
- [ ] `./gradlew test` 통과
- [ ] 범위 밖 파일 수정 없음
- [ ] OpenAPI 갱신
- [ ] _workspace/에 변경 엔드포인트 목록 기록 → qa 교차검증용

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 `.claude/rules/safety.md` 참조.
