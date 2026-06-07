# Evolution — 자체 학습 루프 (관찰 → 축적 → 승격 → 정리)

외부 시스템 없이 키트 안에서 도는 지속 개선 루프. 산출된 하네스의 `review.md` 커맨드와
관찰 Hook(`observe.sh`)이 이 루프를 상시 운영한다. (phase7의 evolution-guide ·
instinct-format · observe-spec 3문서를 한 곳으로 병합.)

## 왜 자동 관찰인가
수동 Bug Log는 사람이 실수를 알아챘을 때만 기록된다 → 누락 많음.
**Hook은 도구 사용 시마다 100% 결정적으로 발동**해 패턴을 빠짐없이 캡처한다.
(스킬 기반 관찰은 50~80%만 발동하므로 Hook이 맞다.)

---

## A. 4박자 루프

### 1. 관찰 (Observe)
- PreToolUse/PostToolUse Hook이 "어떤 상황에서 무슨 도구를 어떻게 썼는지" 캡처.
- 캡처 즉시 점수를 주지 않는다. 원시 관찰(raw)로만 쌓는다.

### 2. 축적 (Instinct)
- 반복 관찰된 패턴을 instinct로 승격(원시 → 명명된 패턴).
- 신뢰도 점수(0.3~0.9) + 도메인 태그(code-style/testing/git/iac/k8s/security) 부여.
- 프로젝트별 격리: `.claude/instincts/<project-hash>/`. (§C 포맷 참조.)

### 3. 승격 (Evolve) — 주 1회
- 같은 도메인의 instinct 3개 이상이 신뢰도 0.7↑로 모이면 묶어서 승격:
  - 행동 규칙 → `claude.md`(헌법) `## Bug Log`/`## Quality Guardrails`에 한 줄.
  - 반복 워크플로 → `.claude/skills/{name}/SKILL.md` (step4 형식).
  - 역할성 패턴 → 에이전트 정의 보강 (step3 형식).
  - 결정적 강제가 필요하면 → `.claude/hooks/`(safety/tdd-gate) 규칙으로 (가장 강함).
- 승격은 **사람 승인 게이트**를 거친다. `review.md`가 후보를 제안하고 사람이 확인·커밋.

### 4. 정리 (Prune) — 주 1회
- 신뢰도 0.3 이하로 떨어진 것, TTL(예: 60일) 동안 재관찰 안 된 것 제거.
- 모순되는 instinct는 삭제 말고 둘 다 두되 점수로 우열 표시 (증거 보존 원칙).

## 주간 리듬 (5~10분)
```
금요일:
  1. 이번 주 관찰 점수 갱신 (재관찰↑ / 사용자수정↓)
  2. 0.7↑ 묶음 1개를 골라 규칙·스킬·훅으로 승격 (사람 승인 후 커밋)
  3. 0.3↓·만료 instinct prune
  4. 토큰 추세 점검: `tools/token-report.sh --runtime <proj>` — 승격으로 claude.md가
     비대해지면 누적 디테일을 docs/ 또는 스킬 references/로 prune (상시 로드 비용 회귀 방지)
```
한 달이면 하네스가 눈에 띄게 프로젝트에 맞춰진다. 완벽 설계 대신 반복 개선.
승격은 규칙을 **늘리는** 압력이므로 4번(토큰 prune)이 균형추다 — 규칙이 늘면 상시 비용도 는다.

## 글로벌 승격 (신중히)
- 같은 instinct가 **여러 프로젝트에서 high-confidence**로 나타나면 글로벌로 올린다.
- 단, 프로젝트 스코핑이 풀리므로 "always validate input" 같은 보편 패턴만.
  특정 레포 컨벤션을 글로벌로 올리면 다른 프로젝트를 오염시킨다.

## API 비용 주의
관찰 Hook은 매 도구 사용마다 도므로 호출·로그가 늘어난다.
관찰 자체는 가벼운 셸로(LLM 호출 없이) 처리하고, 승격(클러스터링)만 주 1회 사람·LLM에 맡긴다.

---

## B. Observe Hook 명세

도구 사용을 100% 결정적으로 캡처하는 Hook. LLM 호출 없이 가벼운 셸로 처리한다.

### 설치 골격
- `.claude/settings.json`(observe hook 등록): `templates/settings.json.tmpl`. matcher "*"로 모든 도구 관찰,
  안전 차단 Hook(safety)·TDD 게이트(tdd-gate)·서킷브레이커와는 별개 파일.
- `.claude/hooks/observe.sh`(캡처 스크립트): `templates/hooks/observe.sh.tmpl`.
  project-hash 스코핑 + redact + append-only.

### 캡처 항목 (raw observation)
| 필드 | 예 |
|------|-----|
| timestamp | 2026-06-07T09:00:00Z |
| phase | pre / post |
| tool | Edit / Bash / Read |
| target | app/.../OrderController.java / `./gradlew test` |
| (post) outcome | ok / error (가능하면) |

### 원칙
- **관찰은 차단하지 않는다.** 항상 `exit 0`. 위험 명령 차단은 safety.sh, TDD는 tdd-gate.sh가 담당.
- **민감정보는 raw에도 남기지 않는다.** secret/PII/prod 파일 경로는 즉시 redact.
- **LLM 호출 없음.** 관찰은 셸로만. 비용·지연 최소화.
- 저장은 `.claude/instincts/<project-hash>/raw/observations.log`(프로젝트 격리).
- Hook 입력은 **stdin JSON**(`.tool_name`, `.tool_input.command`/`.file_path`). jq로 파싱.
  환경변수는 `CLAUDE_PROJECT_DIR` 등만 제공되며 도구명/인자는 stdin으로만 받는다.

---

## C. Instinct 저장 포맷 + 신뢰도 운영

raw 관찰(§B)을 점수 있는 instinct로 올리는 규칙.

### 저장 위치 (프로젝트 격리)
```
.claude/instincts/<project-hash>/
├── raw/observations.log     # 훅이 append (사람이 안 건드림)
└── instincts.md             # 점수 매긴 패턴 (승격 후보 풀)
```
project-hash는 git remote URL 해시. remote 없으면 `no-remote`. A 프로젝트 패턴이 B로
새지 않게 레포 단위로 격리한다.

### instinct 한 줄 포맷 (파싱 쉽게 고정)
`instincts.md` 골격은 `templates/instincts.md.tmpl`. 한 줄 = `[score=N] domain=tag :: 서술 :: seen=N last=날짜`.
- domain 태그: code-style / testing / git / iac / k8s / security / review
- seen: 재관찰 횟수(자동 카운트 가능). last: 마지막 관찰일.

### 신뢰도 점수 (0.3~0.9)
| 점수 | 의미 | 동작 |
|------|------|------|
| 0.3 | 잠정 | 제안만, 강제 안 함 |
| 0.5 | 보통 | 관련 시 적용 |
| 0.7 | 강함 | claude.md/스킬 승격 후보 |
| 0.9 | 거의 확실 | 핵심 규칙·Hook 강제 대상 |

- **상승**: 같은 패턴 반복 관찰 / 사용자가 안 고침 / 다른 출처와 일치.
- **하락**: 사용자가 명시적으로 수정 / 오래 미관찰 / 반증 등장.

> 점수는 사람이 매기는 보조 지표다. seen은 자동이지만, 최종 승격 판단은 사람이 한다.
> 자동 승격을 과신하지 말 것.
