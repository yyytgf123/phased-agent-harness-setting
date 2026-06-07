---
name: add-ci-workflow
description: >
  신규 CI/CD 워크플로 파일을 작성하고 actionlint/validate로만 검증한다.
  "새 파이프라인/워크플로/잡 추가"를 언급하면 반드시 사용하라. infra/ 전용, 하니스에서 prod 배포는 절대 트리거하지 않는다.
  near-miss: 기존 잡의 한 스텝만 손보는 작업이면 트리거하지 말 것(직접 수정).
scope: infra
---

# 신규 CI/CD 워크플로 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 워크플로 파일, 새 파이프라인/잡 신설
- 비트리거(near-miss): 기존 잡의 단일 스텝/버전만 변경 → 직접 수정

## 범위 제약
- 수정 가능: `.github/workflows/` 등 CI 정의 파일만
- 절대 금지: 다른 범위 수정, 하니스에서 prod 배포 워크플로 실제 트리거/dispatch

## 절차

### Step 1 — 패턴 탐색
기존 워크플로 트리거/시크릿/잡 구조 확인.
- 검증: `actionlint`

### Step 2 — 워크플로 작성
트리거·잡·권한(permissions) 최소화로 작성. prod 배포 잡은 수동 승인 게이트로.
- 검증: `actionlint .github/workflows/<file>.yml`

### Step 3 — 정적 검증
시크릿 노출/광범위 권한 없는지 점검.
- 검증: `actionlint`

### Step 4 — 완료 검증 (필수)
- [ ] `actionlint` 통과
- [ ] 범위 밖 파일 수정 없음
- [ ] prod 배포 미트리거, 권한 최소화 확인

## 위험 작업 처리 (해당 시)
- apply/migrate/secret/deploy는 lint/validate까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
