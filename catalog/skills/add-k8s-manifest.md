---
name: add-k8s-manifest
description: >
  신규 k8s 매니페스트 또는 kustomize 오버레이를 작성하고 kubectl apply --dry-run까지만 검증한다.
  "새 워크로드/Service/오버레이 추가"를 언급하면 반드시 사용하라. infra/ 전용, 실제 apply는 금지.
  near-miss: 기존 매니페스트의 replica 수만 바꾸는 작업이면 트리거하지 말 것(직접 수정).
scope: infra
---

# 신규 k8s 매니페스트/오버레이 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 Deployment/Service/ConfigMap, 새 kustomize 오버레이
- 비트리거(near-miss): 기존 매니페스트 replica/이미지 태그만 변경 → 직접 수정

## 범위 제약
- 수정 가능: `infra/` 의 k8s 매니페스트/kustomize 만
- 절대 금지: 다른 범위 수정, `kubectl apply`/`delete` 실제 실행

## 절차

### Step 1 — 패턴 탐색
유사 리소스/네임스페이스/라벨 규칙 확인.
- 검증: `kubectl kustomize overlays/dev`

### Step 2 — 매니페스트 작성
리소스 작성, 라벨/리소스 요청·제한/probe 포함.
- 검증: `kubeconform -strict <files>`

### Step 3 — dry-run 검증
- 검증: `kubectl apply --dry-run=client -k overlays/dev` (server dry-run까지만, 실제 apply 금지)

### Step 4 — 완료 검증 (필수)
- [ ] `kubectl apply --dry-run=client` 통과
- [ ] 범위 밖 파일 수정 없음, 실제 apply 미실행
- [ ] 라벨/네임스페이스/리소스 제한 일관성 확인

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
