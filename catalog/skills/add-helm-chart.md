---
name: add-helm-chart
description: >
  신규 Helm 차트(templates/values)를 작성하고 helm lint + helm template/diff까지만 검증한다.
  "새 차트/릴리스 패키징"을 언급하면 반드시 사용하라. infra/ 전용, prod upgrade/install은 절대 금지.
  near-miss: 기존 차트의 values 한 필드만 올리는 작업이면 트리거하지 말 것(직접 수정).
scope: infra
---

# 신규 Helm 차트 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 차트 골격, 새 템플릿/values 세트 신설
- 비트리거(near-miss): 기존 values 필드 한 개 bump → 직접 수정

## 범위 제약
- 수정 가능: `infra/` 의 차트 디렉터리만
- 절대 금지: 다른 범위 수정, `helm upgrade --install` (특히 prod) 실행

## 절차

### Step 1 — 차트 골격
`Chart.yaml`/`values.yaml`/`templates/` 작성, 값 기본치/주석 명시.
- 검증: `helm lint .`

### Step 2 — 템플릿 작성
리소스 템플릿화, 환경별 values 분리.
- 검증: `helm template . -f values-dev.yaml`

### Step 3 — diff 검증
- 검증: `helm template . | kubeconform -strict` (또는 `helm diff upgrade`, install 금지)

### Step 4 — 완료 검증 (필수)
- [ ] `helm lint` 무오류
- [ ] `helm template` 렌더 결과가 의도와 일치
- [ ] 범위 밖 파일 수정 없음, upgrade/install 미실행

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run/template까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
