# step 2 — SDD 두뇌 작성 (docs/)

> 산출물의 "두뇌"를 만든다. 출력 품질은 입력 사양의 밀도에 비례한다(SDD).
> **여기서 처음 산출물이 생긴다** — 단, 코드가 아니라 설계 문서다.

## 할 일 (대상 프로젝트 `docs/`에 생성)
1. `templates/sdd/prd.md.tmpl` → `docs/prd.md`.
   - 도메인 설명·discovery로 채운다. **`## MVP 제외`(명시적 비목표)를 반드시 구체적으로** 적는다 —
     자율 실행이 불필요 확장에 토큰 낭비하는 걸 막는 핵심 필터.
   - 기능 요구사항은 **테스트 가능한 수용 기준**으로 적는다(뒤 phase의 test_cmd 근거).
2. `templates/sdd/architecture.md.tmpl` → `docs/architecture.md`(설계 의도).
   existing이면 step1 탐색으로 현 구조를 먼저 요약.
3. `templates/sdd/adr.md.tmpl` → `docs/adr/0001-*.md` … 핵심 결정마다 골격 생성(why+트레이드오프).
   세부는 설계/구현 중 채워진다.
4. UI가 있으면 `templates/sdd/ui-guide.md.tmpl` → `docs/ui-guide.md`. 백엔드/인프라 전용이면 생략.
5. `docs/work_orders/`(빈 폴더)·`docs/result_report/`를 준비한다.

## 로드 (이 step만)
- kb: `design-principles.md`
- 템플릿: `sdd/{prd,architecture,adr,ui-guide}.md.tmpl`

## 원칙 / 게이트
- 기획 단계에서 AI에 여러 페르소나(UX·보안·운영)로 5~6회 리뷰시켜 허점을 메운 뒤 확정(권장).
- ◀승인 게이트: PRD(특히 MVP 제외)와 architecture를 사용자가 승인해야 step3로.
