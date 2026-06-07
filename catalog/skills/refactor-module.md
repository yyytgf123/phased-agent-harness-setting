---
name: refactor-module
description: >
  동작을 보존한 채 모듈 내부 구조를 개선하고, 기존 테스트가 계속 GREEN인지로 안전성을 보증한다.
  "리팩터/구조 개선/중복 제거/이름 정리"를 언급하면 반드시 사용하라. app/ 전용, 새 동작 추가 없음.
  near-miss: 새 기능/동작을 추가하는 작업이면 트리거하지 말 것(해당 기능 스킬 사용).
scope: app
---

# 동작 보존 리팩터

## 언제 쓰나 / 안 쓰나
- 트리거: 중복 제거, 추출/이동, 가독성 개선 — 외부 동작 불변
- 비트리거(near-miss): 새 기능/엔드포인트/필드 추가 → add-rest-endpoint 등 기능 스킬

## 범위 제약
- 수정 가능: `app/` 만
- 절대 금지: 다른 범위 수정, 동작/계약 변경

## 절차

### Step 1 — 안전망 확인 (테스트 우선)
대상 모듈을 덮는 기존 테스트가 충분한지 먼저 확인. 부족하면 리팩터 전 특성화 테스트를 먼저 추가한다.
- 검증: `./gradlew test --tests '*TargetModule*'` (GREEN baseline)

### Step 2 — 리팩터
작은 단계로 구조만 변경. 시그니처/동작 유지.
- 검증: `./gradlew compileJava`

### Step 3 — 테스트 불변 확인
같은 테스트가 수정 없이 그대로 통과해야 한다.
- 검증: `./gradlew test --tests '*TargetModule*'`

### Step 4 — 완료 검증 (필수)
- [ ] `./gradlew test` 전체 통과(테스트 코드 변경 없이)
- [ ] 범위 밖 파일 수정 없음
- [ ] 공개 API/동작 변화 없음

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
