---
name: add-db-migration
description: >
  전진(forward-only) DB 마이그레이션 스크립트와 롤백 노트를 작성하고 validate/dry-run까지만 수행한다.
  "스키마 변경/컬럼 추가/마이그레이션 작성"을 언급하면 반드시 사용하라. migrate 실행은 절대 하지 않는다.
  near-miss: 이미 적용된 마이그레이션 파일을 고치는 작업이면 트리거하지 말 것(금지 — 새 마이그레이션을 추가).
scope: app
---

# DB 마이그레이션 작성 (실행 금지)

## 언제 쓰나 / 안 쓰나
- 트리거: 새 테이블/컬럼/인덱스, 데이터 백필 스크립트 신규 작성
- 비트리거(near-miss): 이미 머지/적용된 마이그레이션 수정 → 금지, 반드시 새 파일로 보정

## 범위 제약
- 수정 가능: 마이그레이션 디렉터리(`app/.../migration/` 등)와 관련 엔티티
- 절대 금지: `flyway migrate`/`liquibase update`/`alembic upgrade` 실행, 기존 적용분 변경

## 절차

### Step 1 — 현 스키마/엔티티 탐색
마지막 버전 번호와 엔티티 매핑을 확인해 전진 전용으로 설계.
- 검증: `flyway info`

### Step 2 — 마이그레이션 작성 + 롤백 노트
새 버전 파일 작성. 파괴적 변경엔 롤백 절차를 주석/노트로 명시.
- 검증: `flyway validate`

### Step 3 — 엔티티 정합성 + dry-run
엔티티/매핑을 마이그레이션과 일치시키고 검증.
- 검증: `flyway validate` (migrate 금지)

### Step 4 — 완료 검증 (필수)
- [ ] `flyway validate` 무오류
- [ ] 범위 밖 파일 수정 없음, 기존 마이그레이션 무변경
- [ ] 롤백 노트 작성, 전진 전용 확인

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run/validate까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
