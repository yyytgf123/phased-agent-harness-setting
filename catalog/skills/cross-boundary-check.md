---
name: cross-boundary-check
description: >
  앱·인프라·DB 경계가 서로 맞물리는지 읽기 전용으로 교차 검증하고 불일치를 보고한다.
  "통합/QA 점검", "여러 범위 변경 후 정합성 확인", "배포 전 교차검증"을 언급하면 반드시 사용하라.
  near-miss: 단일 파일/단일 함수 단위 리뷰면 트리거하지 말 것(일반 코드 리뷰).
scope: infra
---

# 교차 경계 정합성 검증 (읽기 전용 QA)

## 언제 쓰나 / 안 쓰나
- 트리거: 여러 범위(app/infra/db)가 함께 바뀐 뒤 경계 일관성 확인
- 비트리거(near-miss): 단일 파일/단위 리뷰 → 일반 리뷰

## 범위 제약
- 수정 가능: 없음 (읽기 전용 — 어떤 파일도 수정 금지)
- 절대 금지: 모든 쓰기/apply/migrate. 발견은 보고만 한다

## 절차

### Step 1 — 변경 표면 수집
변경된 엔드포인트·DTO·env·매니페스트·terraform output·마이그레이션 목록을 모은다.
- 검증: `git diff --name-only`

### Step 2 — 경계 대조
다음 짝을 대조한다: API↔DTO, 앱 env var ↔ k8s/helm config, terraform output ↔ 앱 설정, 마이그레이션 ↔ 엔티티.
- 검증: 각 짝의 키/타입/이름 일치 여부 수기 대조(읽기)

### Step 3 — 보고서 작성
불일치/누락/이름 불일치를 위치와 함께 정리. 수정은 하지 않는다.
- 검증: 보고서에 각 불일치의 양쪽 파일 경로 명시

### Step 4 — 완료 검증 (필수)
- [ ] 4개 경계(API↔DTO, env↔config, tf output↔config, migration↔entity) 모두 점검
- [ ] 어떤 파일도 수정하지 않음(읽기 전용)
- [ ] 불일치 항목마다 양쪽 출처 경로 기재

## 위험 작업 처리 (해당 시)
- 이 스킬은 읽기 전용. 어떤 apply/migrate/deploy도 제안만 하고 실행하지 않는다. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
