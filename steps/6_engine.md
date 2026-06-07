# step 6 — 자율 실행 엔진 (scripts/ + 커맨드)

> 산출된 하네스가 **스스로 가동**할 엔진을 방출한다. 키트의 생성 과정은 자율이 아니다 —
> 여기서 만드는 엔진이 *나중에* 자율로 돈다(Zero-Intervention).

## 할 일 (대상 프로젝트에 생성)
1. `templates/engine/execute.sh.tmpl` → `scripts/execute.sh` (bash+jq 자율 phase 엔진).
   - phase 의존성 순서대로 격리 headless `claude -p` 실행 → phase별 `test_cmd` 게이트 →
     서킷브레이커(연속 N회 실패 정지) → 사람 승인 게이트(approved).
   - 권한모드 acceptEdits(파일편집 자동, Bash는 사람 확인). 타임아웃 gtimeout→없으면 bash 워치독.
   - **실행권한: `chmod +x scripts/execute.sh`**.
2. `templates/engine/phase.json.tmpl` → `scripts/phase.json` (빈 골격, `approved:false`, `mode`=step1 판정).
   phases[]는 비워 두거나 예시만 — 실제 분할은 가동 시 `/harness`가 채운다.
3. `templates/engine/harness.md.tmpl` → 루트 `harness.md` (초기화·단계 분할 커맨드).
4. `templates/engine/review.md.tmpl` → 루트 `review.md` (검증·하네스 강화 커맨드).

## 로드 (이 step만)
- 템플릿: `engine/{execute.sh,phase.json,harness.md,review.md}.tmpl`
- (엔진 동작 규약은 템플릿 자체 주석에)

## 게이트 / 주의
- `phase.json`은 `execute.sh`만 쓴다(모델 읽기 전용) — 레이스 방지.
- 자율 루프는 4중 방어로 경계: 사람 승인 + 서킷브레이커 + 타임아웃 + 블랙리스트/TDD 훅.
- `claude` CLI에 `--max-turns` 없음 → 단일 세션 폭주는 타임아웃으로만 바운드(gtimeout/fallback 필수).
