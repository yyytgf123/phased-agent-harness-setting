# Phase 4 — 스킬 생성 (Skills)

## 이 단계는 무엇을 하나
각 에이전트가 쓸 "어떻게"(워크플로 절차)를 구축한다.
- 스킬마다 → `프로젝트/.claude/skills/{name}/SKILL.md`

## 읽을 상세 (이 폴더)
| 파일 | 무엇을 담음 |
|------|-------------|
| `skill-writing-guide.md` | pushy description, Why 설명, Progressive Disclosure, 본문 500줄 원칙 |

## 쓸 템플릿 (`../../templates/`)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `SKILL.md.tmpl` | `.claude/skills/{name}/SKILL.md` (스킬마다 하나씩) |

## 구축 절차
1. `skill-writing-guide.md`를 읽어 작성 원칙을 확인한다.
2. Phase 1에서 찾은 반복 워크플로를 스킬 후보로 나열 → 승인받은 것만.
3. `../../templates/SKILL.md.tmpl`을 떠서 스킬마다 생성 (**한 번에 1개씩**).
   - **앱 스킬과 인프라 스킬을 섞지 않는다.**
   - description은 pushy + near-miss 구분. 본문 500줄 이내.
   - 검증 명령은 `../phase0_setup/tooling-matrix.md`로 스택 실제 명령 치환.
   - 마지막 단계는 항상 "검증" (무엇 실행→무엇 확인하면 done).
4. 위험 작업은 plan/dry-run까지만 (`../../_shared/safety-rules.md`).

## 스킬 후보 (혼합 레포)
- 앱: add-rest-endpoint, add-entity-migration, write-integration-test
- 인프라: add-terraform-module, update-k8s-deploy, add-alert-rule

## 입력 / 출력
- 입력: Phase 3 에이전트 정의 (각 에이전트가 어떤 스킬을 쓰는지)
- 출력: `.claude/skills/*/SKILL.md` → Phase 5로

## 게이트
- 앱/인프라 스킬 혼합 금지.
- 위험 작업 plan/dry-run까지만.
