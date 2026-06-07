# ORCHESTRATOR — Claude Code 진입 프롬프트

> 이 키트가 무엇인지 전체 설명은 `README.md`를 먼저 보라. 여기는 실행 진입점이다.
> 사용자가 채우는 곳은 **여기 한 군데뿐.** 아래 "■ 입력" 칸 3개만 적어 Claude Code에 붙여넣으면,
> 키트의 `steps/` 폴더를 순서대로 읽으며 **Harness Engineering** 하네스를 찍어낸다.
> step별로 진행하고 **매 step 끝에 멈춰 승인**을 받는다(생성 과정은 자율 아님).

---

## 붙여넣을 프롬프트 (■ 칸만 채우세요)

```
이 프로젝트에 하네스를 구성해줘. 지침 키트는 `<키트 경로>` 에 있다(이 폴더 = 키트 루트).
아래 나오는 `steps/..`·`kb/..`·`catalog/..`·`templates/..` 경로는 모두 이 키트 루트 기준이다.
각 step 파일을 순서대로 읽고 그대로 수행하되, step마다 멈춰 내 승인을 받아라.

# ─────────────────────────────────────────────
# ■ 입력 1. 사용 도구 + 버전
#   - 버전을 적으면 그 버전을 쓴다.
#   - 비우면 적힌 도구끼리 호환 잘 되는 버전을 웹 검색으로 확인 후 지정(현재 연도 기준, LTS 우선).
#   - 이 목록이 catalog에서 생성할 에이전트·스킬을 정한다 — 많이 적을수록 더 풍부하게 생성된다.
# ─────────────────────────────────────────────
repo_type: <app | infra | mixed>

app:
  - <언어>            <버전 또는 비움>      # 예: Java 21
  - <프레임워크>      <버전 또는 비움>      # 예: Spring Boot
  - <빌드 도구>       <버전 또는 비움>      # 예: Gradle
  - <테스트>          <버전 또는 비움>      # 예: JUnit5  (TDD 게이트가 이 명령을 쓴다)
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
#   에이전트·스킬 선택과 PRD/SDD의 근거가 된다. 구체적일수록 좋다.
#   (보안 민감 키워드 — payment/auth/secret 등 — 가 있으면 security-reviewer가 자동 선택된다.)
# ─────────────────────────────────────────────
domain: >
  <예: 주문/결제를 처리하는 백엔드 서비스. REST API 중심, PostgreSQL.
   인프라는 AWS EKS에 Terraform 프로비저닝·Helm 배포. Prometheus 메트릭 수집.
   결제 모듈은 외부 PG 연동이 있어 민감하다.>

# ─────────────────────────────────────────────
# ■ 입력 3. 버전 정책
# ─────────────────────────────────────────────
version_policy: <auto | strict>
#   auto   = 비운 버전을 호환 버전으로 검색·자동 선정
#   strict = 명시한 버전만 사용, 비면 진행 전 나에게 질문

### 실행 순서 (steps/ 폴더 = 단계). 각 step은 `kb/README.md`의 "step 로드 맵" 파일만 로드.
0. `steps/0_setup.md`     → 위 입력으로 스택 확정. 비운 버전은 `kb/version-policy.md`로 검색·선정 후 표로 승인.
1. `steps/1_analyze.md`   → greenfield/existing 판정 + (existing이면) 레포 탐색·보고. 파일 생성 금지.
2. `steps/2_sdd.md`       → `docs/` SDD 두뇌 생성: prd.md(+## MVP 제외)·architecture.md·adr/·ui-guide.md.
3. `steps/3_agents.md`    → `catalog/index.yaml` 매칭으로 `.claude/agents/*` 다수 생성.
4. `steps/4_skills.md`    → `catalog/index.yaml` 매칭으로 `.claude/skills/*` 다수 + 오케스트레이터 생성.
5. `steps/5_constitution.md` → 루트 `claude.md`(헌법) + `.claude/settings.json` + `.claude/hooks/*` 생성.
6. `steps/6_engine.md`    → `scripts/{execute.sh,phase.json}` + 루트 `harness.md`·`review.md` 생성.
7. `steps/7_validate.md`  → 구조·훅·엔진·트리거·토큰 게이트 검증.
공통: 안전·TDD 규칙은 `kb/safety-rules.md`를 산출물 헌법 `claude.md`(# CRITICAL)와 훅에 반영.
공통: 각 step 종료 시 `kb/result-report.md`대로 `docs/result_report/`에 짧은 리포트.
공통: "작업지시서 참고" 지시가 있으면 작업 전 `kb/work-orders.md`대로 `docs/work_orders/`를 먼저 읽어라.

### 공통 제약
- 한 번에 전부 만들지 마라. 각 step 끝에 멈추고 승인받아라.
- 입력 1에 없는 레이어(예: infra 미기재)의 에이전트/스킬은 만들지 마라.
- 검증·테스트 명령은 `kb/tooling-matrix.md`로 내 스택에 맞춰라.
- 앱/인프라 범위 분리. apply/migrate/secret은 plan/dry-run까지만(헌법 # CRITICAL).
- 추측은 "추측"으로 표시하고, 불확실하면 물어라.

지금 step 0부터 시작해.
```

---

## 입력 칸 요약
| 칸 | 무엇을 | 비우면 |
|----|--------|--------|
| ■ 1 도구+버전 | 쓰는 도구(많을수록 에이전트·스킬 풍부). 버전은 선택 | 호환 버전 검색·자동 지정 |
| ■ 2 도메인 설명 | 프로젝트가 뭘 하는지 | 에이전트·스킬·PRD 근거 약해짐 → 가급적 작성 |
| ■ 3 버전 정책 | auto / strict | — |

## 동작 요약
- Claude Code가 `steps/N_*.md`를 차례로 열어 그 step 지침을 따른다(매 step 승인).
- 도구+도메인에 맞는 에이전트·스킬을 `catalog/`에서 **풍부하게** 방출하되, 작업 시엔 필요한 것만 활성화.
- 산출물(`docs/` SDD + `scripts/` 엔진 + `claude.md` 헌법 + `harness.md`/`review.md` + `.claude/`)이
  step 진행에 따라 점진 생성된다. 가동은 산출물의 `/harness` → `execute.sh` → `/review`로(자율).
