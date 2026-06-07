---
name: add-db-migration
description: >
  전진(forward-only) Flyway 마이그레이션 스크립트와 롤백 노트를 작성하고 validate/info까지만 수행한다.
  "스키마 변경/컬럼 추가/마이그레이션 작성"을 언급하면 반드시 사용하라. flyway migrate 실행은 절대 하지 않는다.
  near-miss: 이미 적용된 마이그레이션 파일을 고치는 작업이면 트리거하지 말 것(금지 — 새 마이그레이션을 추가).
scope: app
---

# DB 마이그레이션 작성 (Flyway, 실행 금지)

## 언제 쓰나 / 안 쓰나
- 트리거: 새 테이블(orders, payments 등)/컬럼/인덱스, 데이터 백필 스크립트 신규 작성
- 비트리거(near-miss): 이미 머지/적용된 마이그레이션 수정 → 금지, 반드시 새 파일로 보정

## 범위 제약
- 수정 가능: `app/src/main/resources/db/migration/`(`V{n}__<설명>.sql`)와 관련 JPA 엔티티
- 절대 금지: `flyway migrate` 실행, 기존 적용분(`V1`~`Vn`) 변경

## 절차

### Step 1 — 현 스키마/엔티티 탐색
마지막 버전 번호와 엔티티 매핑을 확인해 전진 전용으로 설계.
- 검증: `./gradlew flywayInfo`

### Step 2 — 마이그레이션 작성 + 롤백 노트
새 버전 파일(`V{n+1}__add_xxx.sql`) 작성. 파괴적 변경(drop/rename)은 다단계로 나누고 롤백 절차를 주석/노트로 명시.
- 검증: `./gradlew flywayValidate`

### Step 3 — 엔티티 정합성 + dry-run
JPA 엔티티/매핑을 마이그레이션과 일치시키고 검증.
- 검증: `./gradlew flywayValidate` (flywayMigrate 금지)

### Step 4 — 완료 검증 (필수)
- [ ] `./gradlew flywayValidate` 무오류
- [ ] 범위 밖 파일 수정 없음, 기존 마이그레이션 무변경
- [ ] 롤백 노트 작성, 전진 전용 확인
- [ ] (해당 시) `_workspace/`에 스키마 변경 기록 → qa 교차검증용

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run/validate까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
