---
name: add-terraform-module
description: >
  신규 Terraform 모듈 추가 시 변수·출력·plan 검증을 함께 구성한다.
  새 인프라 리소스/모듈 추가를 언급하면 반드시 사용. infra/ 범위 전용.
  기존 모듈 변수만 바꾸는 경우엔 트리거하지 않음.
scope: infra
---

# 신규 Terraform 모듈 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 모듈 디렉터리, 새 리소스 집합
- 비트리거(near-miss): 기존 모듈 변수값만 변경

## 범위 제약
- 수정 가능: `infra/` 만
- 절대 금지: 다른 범위(`app/` 등) 수정, apply 실행

## 절차

### Step 1 — 모듈 골격
`infra/modules/<name>/` 에 main/variables/outputs 작성.
- 검증: `terraform fmt -check`

### Step 2 — 호출부 연결
환경별(dev/stg/prod) 디렉터리에서 모듈 호출.
- 검증: `terraform validate`

### Step 3 — plan 검증
- 검증: `terraform plan` (apply 금지)

### Step 4 — 완료 검증 (필수)
- [ ] `terraform validate` 무오류
- [ ] `terraform plan` 차이가 의도와 일치
- [ ] 범위 밖 파일 수정 없음

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 `.claude/rules/safety.md` 참조.
