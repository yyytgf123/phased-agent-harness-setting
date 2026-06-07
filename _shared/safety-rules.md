# Safety Rules — 위험 명령 차단 (공통 블록)

> CLAUDE.md의 NEVER 섹션과 각 에이전트 정의에 반영한다.
> 생성물 골격: `.claude/rules/safety.md` ← `../templates/rules-safety.md.tmpl`,
> `.claude/settings.json` ← `../templates/settings.json.tmpl`, `.claude/hooks/safety.sh` ← `../templates/hooks/safety.sh.tmpl`.

## 절대 금지 (사람 승인 없이 실행 불가)
- `terraform apply` / `destroy` → plan까지만
- `kubectl apply` / `delete` → `--dry-run=client`까지만
- `helm upgrade/install` (prod) → template/diff까지만
- DB 마이그레이션 실행 (flyway migrate, liquibase update, alembic upgrade) → 작성까지만
- secret/자격증명 읽기·출력 (*.env, *-prod.*, tfstate, kubeconfig, *.pem)
- `rm -rf` , `git push --force` , `git reset --hard`

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
