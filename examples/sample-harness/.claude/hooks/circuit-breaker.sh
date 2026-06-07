#!/bin/bash
# .claude/hooks/circuit-breaker.sh (step5 산출물) — PreToolUse(Bash). 자율 루프 트립 시 세션 내에서도 정지(exit 2).
# scripts/phase.json 의 .circuit_breaker.tripped 가 true면 더 이상의 Bash 실행을 막는다.

command -v jq >/dev/null || exit 0
STATE="${CLAUDE_PROJECT_DIR:-.}/scripts/phase.json"
[ -f "$STATE" ] || exit 0

TRIPPED=$(jq -r '.circuit_breaker.tripped // false' "$STATE" 2>/dev/null)
if [ "$TRIPPED" = "true" ]; then
  REASON=$(jq -r '.circuit_breaker.tripped_reason // "unknown"' "$STATE" 2>/dev/null)
  echo "차단(서킷브레이커): 자율 루프가 연속 실패로 정지됨 — '$REASON'. phase.json 점검 후 사람이 재개." >&2
  exit 2
fi
exit 0
