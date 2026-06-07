#!/bin/bash
# .claude/hooks/tdd-gate.sh (step5 산출물) — PreToolUse(Edit|Write). 테스트 없는 구현 파일 작성 차단(exit 2).
# 입력: stdin JSON (.tool_input.file_path). 정책: 루트 claude.md '# CRITICAL — TDD'. (orders-service: JUnit5)

command -v jq >/dev/null || exit 0
INPUT=$(cat)
FP=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')
[ -z "$FP" ] && exit 0
ROOT="${CLAUDE_PROJECT_DIR:-.}"

# 테스트/비구현 파일은 통과 (테스트는 항상 먼저 쓸 수 있어야 함)
case "$FP" in
  *Test*|*test*|*spec*|*.md|*.txt|*.json|*.yaml|*.yml|*.tf|*.tfvars|*.sh|*.sql) exit 0 ;;
esac
# 구현 대상 확장자만 게이트
case "$FP" in
  *.java|*.kt) : ;;
  *) exit 0 ;;
esac

# greenfield 부트스트랩 예외: 테스트가 0개면 첫 구현 허용
HAS_TEST=$(find "$ROOT" -type f \( -iname '*Test.java' -o -iname '*Test.kt' \) 2>/dev/null | head -1)
[ -z "$HAS_TEST" ] && exit 0

# 대응 테스트 존재 추정: 같은 stem의 *Test 파일
BASE=$(basename "$FP"); STEM="${BASE%.*}"
if find "$ROOT" -type f \( -iname "${STEM}Test.*" -o -iname "${STEM}IT.*" \) 2>/dev/null | grep -q .; then
  exit 0
fi

echo "차단(TDD): '${BASE}'의 실패 테스트가 먼저 없습니다. ${STEM}Test 를 먼저 작성하세요 — claude.md '# CRITICAL — TDD'." >&2
exit 2
