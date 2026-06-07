# Result Report — 작업 완료 리포트 규칙

작업(또는 각 Phase)이 끝날 때마다 루트 `docs/result_report/`에 리포트를 한 개 남긴다.
무슨 작업을 했는지 나중에 추적하기 위한 가벼운 기록.

## 위치 / 파일명
```
docs/result_report/YYYYMMDD_HHMMSS.md
```
- 예: `docs/result_report/20260607_142530.md`
- 폴더 없으면 생성. 파일은 작업 단위로 새로 만든다(덮어쓰지 않음).

## 형식 (짧게 — 한 화면 이내)
골격은 `../templates/result-report.md.tmpl` (작업/Phase/변경/결과/다음 5줄).

## 규칙
- **짧게.** 위 5줄 골격을 넘기지 않는다. 서술형 문단 금지.
- 민감정보(secret/키/토큰) 기록 금지 (`safety-rules.md`).
- 작업이 여러 Phase에 걸치면 Phase별로 나누지 말고 작업 1건당 리포트 1개.
- 작업참고서/지시서 기반이면 `작업:` 줄에 근거를 한 줄로 남긴다 (예: `근거: work_orders/order-q3.md`).

## architecture.md 와의 차이 (혼동 주의)
- result_report = 작업마다 **새 파일**, 무엇을 **했는지**(이력).
- `docs/architecture.md` = 항상 **1개**, 지금 구조가 **어떻게 생겼는지**(현재 상태). → `architecture-doc.md` 참조.
