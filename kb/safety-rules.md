# Safety Rules — 위험 명령 차단 (공통 블록)

> 안전 **정책 텍스트**는 산출물의 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 섹션 단일 소스에 박는다
> (옛 `.claude/rules/safety.md`는 폐지 — 헌법 + 훅으로 병합).
> 안전 **강제**는 `.claude/settings.json` ← `../templates/settings.json.tmpl` +
> `.claude/hooks/safety.sh` ← `../templates/hooks/safety.sh.tmpl` (결정적 차단).
> 추가 게이트: `tdd-gate.sh`(테스트 없는 구현 차단) · `circuit-breaker.sh`(자율 루프 트립 시 정지).

## 절대 금지 (사람 승인 없이 실행 불가)
- `terraform apply` / `destroy` → plan까지만
- `kubectl apply` / `delete` → `--dry-run=client`까지만
- `helm upgrade/install` (prod) → template/diff까지만
- DB 마이그레이션 실행 (flyway migrate, liquibase update, alembic upgrade) → 작성까지만
- secret/자격증명 읽기·출력 (*.env, *-prod.*, tfstate, kubeconfig, *.pem)
- `rm -rf` , `git push --force`/`-f` , `git reset --hard` (`--force-with-lease`도 검토 후 사람 실행)

## TDD 게이트 (구현은 실패 테스트 뒤에만)
- 대응 테스트(실패하는)가 없으면 구현 파일 작성 금지 — `tdd-gate.sh`가 `Edit|Write`에서 차단(exit 2).
- greenfield 첫 테스트 파일 작성은 예외 허용(테스트가 0개인 부트스트랩). 스택별 테스트 경로 매핑은 `tooling-matrix.md`.

## bash allowlist 권장
허용: ls, cat, grep, find, git(읽기/커밋), ./gradlew, mvn, npm, pytest,
      terraform plan/validate, tflint, kubeval, kubectl get/describe,
      kubectl ... --dry-run, helm lint/template, promtool check
차단: 위 "절대 금지" 전부 + 알 수 없는 외부 다운로드 실행

## 범위 침범 차단
- 앱 에이전트: infra/, monitoring/, helm values 수정 금지
- 인프라 에이전트: app/ 소스 수정 금지
- 침범 시: 거부 + 담당 에이전트로 위임 또는 사람 보고

## 표준 응답
"이 작업은 <명령>을 요구하는데 prod 영향이 있어 직접 실행하지 않습니다.
 <plan/dry-run 결과>를 보여드리니 검토 후 직접 실행하세요."

## 시스템 차원 강제 (텍스트 규칙보다 우선)
"~하지 마라" 문장은 무시될 수 있으므로, 가능하면 Hook으로 결정적으로 막는다.
설정: `.claude/settings.json` + `.claude/hooks/*.sh`.

| Hook | 시점 | 개발/인프라 예 |
|------|------|----------------|
| PreToolUse | 도구 실행 전 | `git commit`/`terraform apply` 매칭 시 위험 명령 차단(차단=exit 2) |
| PostToolUse | 실행 후 | 파일 변경 시 자동 린트(spotless/tflint) |
| Stop | 완료 선언 전 | 테스트·범위 검증 통과 못 하면 완료 차단 |

> Hook I/O 규약(Claude Code): matcher는 **도구 이름만** 매칭(`"Bash"` 등). 인자(git commit/terraform apply 등) 분기는 훅이 **stdin JSON**(`.tool_input.command`)을 jq로 파싱해 처리. 차단은 **exit 2**(exit 1은 비차단=통과).

차단 Hook 골격(커밋 직전 시크릿 차단 등)은 `../templates/hooks/safety.sh.tmpl` 참조.
> 상세 원칙은 design-principles.md 참조.
