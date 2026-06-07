#!/bin/bash
# .claude/hooks/safety.sh (Phase 3 산출물) — PreToolUse 차단형 Hook. 위험하면 exit 2(차단), 아니면 exit 0.
# 입력: stdin JSON (.tool_name / .tool_input.command). 차단=exit 2, exit 1은 비차단. 전체 규칙: .claude/rules/safety.md.

# jq 없으면 인자 파싱 불가 → 차단 불가. 작업은 막지 않되(fail-open) 경고.
command -v jq >/dev/null || { echo "safety.sh: jq 필요(brew install jq) — 미설치 시 위험명령 차단 불가" >&2; exit 0; }

INPUT=$(cat)
CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

# 위험 명령 차단 — apply/migrate/force는 plan/dry-run까지만 (orders-service: Spring Boot + Terraform/EKS)
case "$CMD" in
  *"terraform apply"*|*"kubectl apply"*|*"flyway migrate"*|*"git push --force"*|*"git push -f"*)
    echo "차단: '$CMD'은 사람 승인 필요. plan/dry-run까지만." >&2; exit 2 ;;
esac

# git commit 직전 시크릿/대용량 plan 산출물 스테이징 차단
case "$CMD" in
  *"git commit"*)
    if git diff --cached --name-only 2>/dev/null | grep -qE '\.env$|tfstate|-prod\.'; then
      echo "차단: 민감 파일이 스테이징됨. 제거 후 커밋." >&2; exit 2
    fi ;;
esac

exit 0
