# step 1 — 분석 (Analyze: greenfield/existing + discovery)

> 레포를 탐색만 한다. **파일 생성 금지, 보고만.** 추측으로 하네스를 만드는 걸 막는 관문.

## 할 일
1. **모드 판정**: 코드가 비었으면 **greenfield**(PRD/SDD부터), 코드가 있으면 **existing**(discovery-first).
2. **레포 분류**: 앱 전용 / 인프라 전용 / 혼합(mixed).
3. existing이면 `kb/discovery-checklist.md` 6항목 조사: 빌드/테스트/린트 명령, 디렉터리 지도,
   기존 컨벤션, 위험지대(DB migrate·prod secret), 기존 `.claude/`, 핵심 작업 유형.
4. greenfield면 도메인 설명 기반으로 만들 범위·핵심 작업 유형을 가설로 정리(코드 없음 명시).
5. `templates/reports/discovery.md.tmpl` 형식으로 보고.

## 로드 (이 step만)
- kb: `discovery-checklist.md`, `design-principles.md`
- 템플릿: `reports/discovery.md.tmpl`

## 원칙 / 출력 / 게이트
- 추측한 부분은 "추측"으로 표시. **어떤 파일도 만들거나 고치지 않는다.**
- 출력: 모드(greenfield/existing) + repo_type + 탐색 보고서 → step2로.
- ◀승인 게이트: 보고 내용(특히 모드·분류·위험지대)을 사용자가 확인.
