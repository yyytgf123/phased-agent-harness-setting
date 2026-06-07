# ORCHESTRATOR — Claude Code 진입 프롬프트

> 이 키트가 무엇인지 전체 설명은 `README.md`를 먼저 보라. 여기는 실행 진입점이다.
> 사용자가 채우는 곳은 **여기 한 군데뿐.** 아래 "■ 입력" 칸 3개만 적어
> Claude Code에 붙여넣으면, 키트의 phase 폴더를 순서대로 읽으며 하네스를 만든다.
> STACK.yaml 같은 별도 파일은 채울 필요 없다.

---

## 붙여넣을 프롬프트 (■ 칸만 채우세요)

```
이 프로젝트에 하네스를 구성해줘. 지침 키트는 `<./harness-template/>` 에 있다.
각 단계 폴더의 README.md를 읽고 그대로 수행하되, 단계마다 멈춰 내 승인을 받아라.

# ─────────────────────────────────────────────
# ■ 입력 1. 사용 도구 + 버전
#   - 버전을 적으면 그 버전을 쓴다.
#   - 버전을 비우면("" 또는 생략) 적힌 도구들끼리 호환이 가장 잘 되는 버전을
#     웹 검색으로 확인한 뒤 지정한다. (현재 연도 기준으로 검색, LTS 우선)
# ─────────────────────────────────────────────
repo_type: <app | infra | mixed>

app:
  - <언어>            <버전 또는 비움>      # 예: Java 21  /  Java
  - <프레임워크>      <버전 또는 비움>      # 예: Spring Boot
  - <빌드 도구>       <버전 또는 비움>      # 예: Gradle
  - <테스트>          <버전 또는 비움>      # 예: JUnit5
  - <린트/포맷>       <버전 또는 비움>
  - <DB / 마이그레이션 / API문서>           # 예: PostgreSQL, Flyway, springdoc

infra:                                       # 없으면 이 블록 통째로 생략
  - <IaC>             <버전 또는 비움>      # 예: Terraform
  - <클라우드>                              # 예: AWS
  - <컨테이너/오케스트레이터/패키징>        # 예: Docker, Kubernetes, Helm
  - <CI/CD>                                 # 예: GitHub Actions

monitoring:                                  # 없으면 생략
  - <메트릭/대시보드/로깅/트레이싱>         # 예: Prometheus, Grafana

# ─────────────────────────────────────────────
# ■ 입력 2. 도메인 설명 (이 프로젝트가 뭘 하는지, 자유 서술)
#   에이전트 역할·스킬 후보를 정하는 근거가 된다. 구체적일수록 좋다.
# ─────────────────────────────────────────────
domain: >
  <예: 주문/결제를 처리하는 백엔드 서비스. REST API 중심이고 PostgreSQL을 쓴다.
   인프라는 AWS EKS에 Terraform으로 프로비저닝하고 Helm으로 배포한다.
   Prometheus로 메트릭을 수집한다. 결제 모듈은 외부 PG 연동이 있어 민감하다.>

# ─────────────────────────────────────────────
# ■ 입력 3. 버전 정책
# ─────────────────────────────────────────────
version_policy: <auto | strict>
#   auto   = 비운 버전을 호환 버전으로 검색·자동 선정
#   strict = 명시한 버전만 사용, 비면 진행 전 나에게 질문

### 실행 순서 (폴더 = 단계)
0. `phase/phase0_setup/README.md` → 위 입력으로 스택 확정.
   비운 버전은 `phase/phase0_setup/version-policy.md` 규칙대로 **검색 후** 호환 버전 선정.
   선정 결과를 표로 보여주고 내 승인을 받아라.
1. `phase/phase1_discovery/README.md` → 레포 탐색·보고만 (파일 생성 금지).
2. `phase/phase2_architecture/README.md` → 실행모드+패턴+에이전트 분리 설계 (설계만).
3. `phase/phase3_agents/README.md` → `.claude/agents/*.md` + 루트 `CLAUDE.md` 생성.
4. `phase/phase4_skills/README.md` → `.claude/skills/*/SKILL.md` 생성 (한 번에 1개씩).
5. `phase/phase5_orchestration/README.md` → 오케스트레이터 스킬 생성.
   이 단계 종료 시 `_shared/architecture-doc.md` 규칙대로 `docs/architecture.md`(전체 구조 스냅샷)를 최초 생성.
6. `phase/phase6_validation/README.md` → 트리거·범위·with/without 검증.
7. `phase/phase7_evolution/README.md` → (실사용 단계) 관찰 Hook 설치 + 지속 개선 루프 구성.
공통: `_shared/safety-rules.md`의 금지 규칙을 Phase 3·4 산출물에 반영.
공통: 각 단계가 끝나면 `_shared/result-report.md` 규칙대로 `docs/result_report/YYYYMMDD_HHMMSS.md`에 짧은 리포트를 남겨라.
공통: 구조(에이전트/스킬/오케스트레이터/Hook)가 바뀌면 `_shared/architecture-doc.md` 규칙대로 `docs/architecture.md`를 **부분 편집으로만** 갱신해라(전체 재작성 금지 — 토큰 절약).
공통: 내 프롬프트에 "작업참고서/작업지시서를 참고하라"는 지시가 있으면, 작업 전 `_shared/work-orders.md` 규칙대로 `docs/work_orders/`를 먼저 읽고 그에 맞춰 작업해라.

### 공통 제약
- 한 번에 전부 만들지 마라. 각 단계 끝에 멈추고 승인받아라.
- 입력 1의 도구 중 없는 레이어(예: infra 미기재)의 에이전트/스킬은 만들지 마라.
- 검증 명령은 phase0의 tooling-matrix로 내 스택에 맞춰라.
- 앱/인프라 범위 분리, apply/migrate/secret은 plan/dry-run까지만.
- 추측은 "추측"으로 표시하고, 불확실하면 물어라.

지금 0단계부터 시작해.
```

---

## 입력 칸 요약
| 칸 | 무엇을 | 비우면 |
|----|--------|--------|
| ■ 1 도구+버전 | 쓰는 도구. 버전은 선택 | 호환 버전 검색·자동 지정 |
| ■ 2 도메인 설명 | 프로젝트가 뭘 하는지 | 에이전트/스킬 설계 근거 약해짐 → 가급적 작성 |
| ■ 3 버전 정책 | auto / strict | — |

## 동작 요약
- Claude Code가 `phaseN_*/README.md`를 차례로 열어 그 단계 지침을 따른다.
- 비운 버전은 phase0에서 검색으로 호환 조합을 정하고 표로 승인받는다.
- 산출물(.claude/agents, .claude/skills)은 단계가 진행되며 점진 생성된다.