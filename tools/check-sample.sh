#!/bin/bash
# examples/sample-harness 픽스처 점검 — 샘플이 키트 규칙에서 표류하지 않도록 한 번에 검사.
# 하나라도 실패하면 non-zero exit. Phase 6 검증/샘플 수정 시 실행.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SAMPLE="$ROOT/examples/sample-harness"
HOOKS="$SAMPLE/.claude/hooks"
fail=0
note() { printf '%-46s %s\n' "$1" "$2"; }

# 1) 토큰 게이트 (CLAUDE.md ≤60줄 · skill ≤500줄 · 안전 표준응답 단일소스)
if bash "$ROOT/tools/token-report.sh" --gate "$SAMPLE" >/dev/null 2>&1; then
  note "token gate" "OK"
else
  note "token gate" "FAIL (token-report.sh --gate)"; fail=1
fi

# 2) 훅 문법 검사
for f in "$HOOKS"/*.sh; do
  [ -e "$f" ] || { note "hooks present" "FAIL (no .sh in $HOOKS)"; fail=1; break; }
  if bash -n "$f" 2>/dev/null; then note "syntax $(basename "$f")" "OK"
  else note "syntax $(basename "$f")" "FAIL"; fail=1; fi
done

# 3) settings.json JSON 유효성
if jq -e . "$SAMPLE/.claude/settings.json" >/dev/null 2>&1; then
  note "settings.json valid" "OK"
else
  note "settings.json valid" "FAIL (jq)"; fail=1
fi

# 4) 금지 잔재 (깨진 훅 규약이 다시 새어들지 않게)
if grep -rnE 'Bash\(git commit\*\)|TOOL_CMD|TOOL_NAME|TOOL_TARGET' "$SAMPLE/.claude" >/dev/null 2>&1; then
  note "no broken-hook leftovers" "FAIL (matcher/env-var 잔재)"; fail=1
else
  note "no broken-hook leftovers" "OK"
fi
# 훅 안에서 차단을 exit 1로 하는 실수 차단(차단은 exit 2). 주석 제외하고 실제 코드만 검사.
if sed 's/#.*//' "$HOOKS"/*.sh | grep -qE '\bexit 1\b'; then
  note "no 'exit 1' in hooks" "FAIL (차단은 exit 2)"; fail=1
else
  note "no 'exit 1' in hooks" "OK"
fi

# 5) settings가 참조하는 훅이 실재 + 실행권한
for h in safety.sh observe.sh; do
  if [ -x "$HOOKS/$h" ]; then note "executable $h" "OK"
  else note "executable $h" "FAIL (없음/실행권한)"; fail=1; fi
done

echo "----------------------------------------------"
if [ "$fail" -eq 0 ]; then echo "check-sample: PASS"; exit 0
else echo "check-sample: FAIL"; exit 1; fi
