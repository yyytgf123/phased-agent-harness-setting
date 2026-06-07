#!/bin/bash
# .claude/hooks/safety.sh (step5 산출물) — PreToolUse 차단형 Hook. 위험하면 exit 2(차단), 아니면 exit 0.
# 입력: stdin JSON (.tool_name / .tool_input.command). 안전 정책 단일소스: 루트 claude.md '# CRITICAL — Safety'.

command -v jq >/dev/null || { echo "safety.sh: jq 필요(brew install jq) — 미설치 시 위험명령 차단 불가" >&2; exit 0; }

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

# 파괴적·prod 영향 명령 차단 (orders-service: Spring Boot + Terraform/EKS + Flyway)
case "$CMD" in
  *"terraform apply"*|*"terraform destroy"*|*"kubectl apply"*|*"kubectl delete"* \
  |*"helm upgrade"*|*"helm install"*|*"flyway migrate"* \
  |*"git push --force"*|*"git push -f"*|*"git reset --hard"*|*"rm -rf"*)
    echo "차단: '$CMD'은 사람 승인 필요(파괴적/prod 영향). plan/dry-run까지만 — claude.md '# CRITICAL — Safety'." >&2
    exit 2 ;;
esac

# git commit 직전 시크릿/상태파일 스테이징 차단
case "$CMD" in
  *"git commit"*)
    if git diff --cached --name-only 2>/dev/null | grep -qE '\.env$|tfstate|-prod\.|\.pem$|kubeconfig'; then
      echo "차단: 민감 파일이 스테이징됨. 제거 후 커밋." >&2; exit 2
    fi ;;
esac

exit 0
