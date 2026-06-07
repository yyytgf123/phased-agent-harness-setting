---
name: add-alert-rule
description: >
  신규 Prometheus 알림 규칙을 작성하고 promtool로 검증하며, 필요 시 Grafana 패널을 함께 둔다.
  "새 알림/얼럿 추가", "이 지표에 경보 걸어줘"를 언급하면 반드시 사용하라. monitoring/ 전용.
  near-miss: 기존 알림의 임계값만 조정하는 작업이면 트리거하지 말 것(직접 수정).
scope: infra
---

# 신규 Prometheus 알림 규칙 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 alerting rule, 새 경보 시나리오 신설
- 비트리거(near-miss): 기존 규칙 threshold/for 만 조정 → 직접 수정

## 범위 제약
- 수정 가능: `monitoring/` 의 rules/대시보드만
- 절대 금지: 앱/인프라 범위 수정, 라이브 알림 매니저 직접 변경

## 절차

### Step 1 — 지표 탐색
대상 메트릭 존재/라벨/기존 규칙 패턴 확인.
- 검증: `promtool check config prometheus.yml`

### Step 2 — 규칙 작성
expr/for/labels/annotations 작성. severity·runbook 링크 포함.
- 검증: `promtool check rules rules/<file>.yml`

### Step 3 — 규칙 테스트(선택) + Grafana 패널(선택)
가능하면 `promtool test rules`로 단위 검증, 필요 시 대시보드 패널 추가.
- 검증: `promtool test rules tests/<file>_test.yml`

### Step 4 — 완료 검증 (필수)
- [ ] `promtool check rules` 통과
- [ ] 범위 밖 파일 수정 없음
- [ ] severity/annotation/runbook 정보 포함

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run/check까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
