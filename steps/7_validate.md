# step 7 — 검증 (Validation)

> 만든 하네스가 실제로 작동·효과 있는지 측정한다. 만들고 끝내면 그냥 문서다.

## 할 일 (`kb/skill-testing-guide.md` 상세)
1. **구조 검증** — 산출물 트리 확인: 루트 `claude.md`·`harness.md`·`review.md`,
   `docs/{prd,architecture,adr}`, `scripts/{execute.sh,phase.json}`,
   `.claude/{agents,skills,hooks,settings.json}`. `.claude/rules/` 잔재 없어야 함.
2. **훅 검증** — `bash -n` 문법, 실행권한(+x), `settings.json`에 등록됨, 경로가 `${CLAUDE_PROJECT_DIR}` 절대경로.
   - 단위 점검: `safety.sh`에 위험명령 JSON 주입 → exit 2. `tdd-gate.sh`에 테스트 없는 구현경로 → exit 2.
     `circuit-breaker.sh`에 tripped=true phase.json → exit 2.
3. **엔진 dry-run** — `phase.json`(approved=false)로 `execute.sh` → exit 3(승인 게이트 동작 확인).
4. **트리거 검증** — 스킬 should-trigger / should-NOT(near-miss) 시나리오로 오발·누락 점검.
5. **범위 침범 테스트** — backend-dev에 infra 작업, infra-dev에 apply 시켜 막히는지.
6. **토큰 게이트** — `tools/token-report.sh --gate <프로젝트>`. 상시 비용 임계 위반 시 non-zero → 재작업.
   규칙은 `kb/metrics.md`. (샘플 픽스처를 손댔으면 `tools/check-sample.sh` 통과 필수.)

## 로드 (이 step만)
- kb: `skill-testing-guide.md`, `metrics.md`
- 템플릿: `reports/validation.md.tmpl`

## 출력 / 반복 루프
- 출력: 검증 리포트 + 고칠 것 우선순위.
- 트리거 문제 → step4(스킬 description) / 범위 침범·규칙 무시 → step3·5 / 엔진 문제 → step6 수정 후 재측정.
- ◀승인 게이트: "가동 준비" 확인 후 → 산출물 가동(`/harness` → `execute.sh` → `/review`).

## 가동 이후 (산출물 운영 — 자율)
검증을 통과하면 산출된 하네스를 가동한다: `/harness`로 단계 분할·승인 → `bash scripts/execute.sh`로
자율 실행 → `/review`로 검증·강화. 지속 개선(관찰→축적→승격→정리)은 `kb/evolution.md` 루프로 상시.
