---
name: add-terraform-module
description: >
  신규 Terraform 모듈(main/variables/outputs)을 작성하고 fmt→validate→plan까지만 검증한다.
  "새 인프라 리소스/모듈 추가"를 언급하면 반드시 사용하라. infra/ 전용, apply는 절대 하지 않는다.
  near-miss: 기존 모듈의 변수값만 바꾸는 작업이면 트리거하지 말 것(직접 수정).
scope: infra
---

# 신규 Terraform 모듈 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 모듈 디렉터리, 새 리소스 집합 신설
- 비트리거(near-miss): 기존 모듈 변수값만 변경 → 직접 수정

## 범위 제약
- 수정 가능: `infra/` 만
- 절대 금지: 다른 범위(`app/` 등) 수정, `terraform apply`/`destroy` 실행

## 절차

### Step 1 — 모듈 골격
`infra/modules/<name>/`에 main/variables/outputs 작성, 입력/출력 계약 명시.
- 검증: `terraform fmt -check`

### Step 2 — 호출부 연결
환경별(dev/stg/prod) 디렉터리에서 모듈 호출, 변수 전달.
- 검증: `terraform validate`

### Step 3 — plan 검증
- 검증: `terraform plan` (apply 금지)

### Step 4 — 완료 검증 (필수)
- [ ] `terraform validate` 무오류
- [ ] `terraform plan` 차이가 의도와 일치
- [ ] 범위 밖 파일 수정 없음, apply 미실행

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
