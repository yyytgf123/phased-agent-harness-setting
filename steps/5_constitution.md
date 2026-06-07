# step 5 — 헌법 + 가드레일 (claude.md · settings.json · hooks)

> 시스템 강제 장치를 박는다. 말이 아닌 시스템으로 — 권한차단 > 훅 > CI > 텍스트(`kb/design-principles.md`).

## 할 일 (대상 프로젝트에 생성)
1. `templates/claude.md.tmpl` → 루트 **`claude.md`(헌법, 단일 소스)**.
   - `# CRITICAL — Safety`(`kb/safety-rules.md` 반영)와 `# CRITICAL — TDD`를 최상위로.
   - Map/Build&Test/Technical Constraints(docs/architecture.md에서)/Quality Guardrails(anti-slop)/
     Docs&Work Orders(`kb/work-orders.md`·`kb/architecture-doc.md`)/빈 Bug Log를 채운다.
   - 옛 `.claude/rules/safety.md`는 만들지 않는다(폐지). 에이전트·스킬은 헌법을 참조.
2. `templates/settings.json.tmpl` → `.claude/settings.json` (훅 등록).
3. `templates/hooks/*.sh.tmpl` → `.claude/hooks/`:
   - `safety.sh`(위험명령 차단) · `tdd-gate.sh`(테스트 없는 구현 차단) ·
     `circuit-breaker.sh`(자율 루프 트립 시 정지) · `observe.sh`(비차단 관찰).
   - 위험 명령·TDD 테스트 경로 매핑을 스택에 맞춰 채운다(`kb/tooling-matrix.md`).
   - **훅 경로는 반드시 `${CLAUDE_PROJECT_DIR}/.claude/hooks/...`**(상대경로 금지 — 서브에이전트 cwd 어긋남).
   - **생성한 훅에 실행권한: `chmod +x .claude/hooks/*.sh`** (안 하면 런타임 Permission denied).

## 로드 (이 step만)
- kb: `safety-rules.md`, `design-principles.md`, `work-orders.md`, `architecture-doc.md`
- 템플릿: `claude.md.tmpl`, `settings.json.tmpl`, `hooks/*.sh.tmpl`

## 게이트
- 헌법은 60줄 강박 없이 정책을 담되, 깊은 디테일은 docs/로(상시 비용 관리는 `kb/metrics.md`).
- 안전·TDD는 `# CRITICAL` 태그로 — 충돌 시 이 규칙이 작업지시서보다 우선.
