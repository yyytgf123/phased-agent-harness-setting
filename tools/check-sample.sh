#!/bin/bash
# examples/sample-harness 픽스처 점검 — 샘플이 키트 규칙에서 표류하지 않도록 한 번에 검사.
# 하나라도 실패하면 non-zero exit. step7 검증/샘플 수정 시 실행.
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SAMPLE="$ROOT/examples/sample-harness"
HOOKS="$SAMPLE/.claude/hooks"
fail=0
note() { printf '%-48s %s\n' "$1" "$2"; }

# 1) 토큰 게이트 (claude.md ≤120줄 · skill ≤500줄 · 안전 단일소스 · rules/ 잔재 없음)
if bash "$ROOT/tools/token-report.sh" --gate "$SAMPLE" >/dev/null 2>&1; then
  note "token gate" "OK"
else
  note "token gate" "FAIL (token-report.sh --gate)"; fail=1
fi

# 2) 새 구조 산출물 존재
for p in claude.md harness.md review.md docs/prd.md docs/architecture.md \
         scripts/execute.sh scripts/phase.json .claude/settings.json; do
  if [ -e "$SAMPLE/$p" ]; then note "exists $p" "OK"; else note "exists $p" "FAIL (없음)"; fail=1; fi
done
# SDD adr 하나 이상
if ls "$SAMPLE"/docs/adr/*.md >/dev/null 2>&1; then note "exists docs/adr/*.md" "OK"; else note "exists docs/adr/*.md" "FAIL"; fail=1; fi
# 에이전트·스킬이 풍부하게(>=4) 생성됐는지
na=$(find "$SAMPLE/.claude/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
ns=$(find "$SAMPLE/.claude/skills" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' ')
[ "${na:-0}" -ge 4 ] && note "agents >=4 ($na)" "OK" || { note "agents >=4 ($na)" "FAIL"; fail=1; }
[ "${ns:-0}" -ge 4 ] && note "skills >=4 ($ns)" "OK" || { note "skills >=4 ($ns)" "FAIL"; fail=1; }

# 3) 폐지된 .claude/rules/ 잔재 금지
if [ -e "$SAMPLE/.claude/rules" ]; then note "no .claude/rules/" "FAIL (폐지됨)"; fail=1; else note "no .claude/rules/" "OK"; fi
# "폐지" 안내 주석은 허용, 실제 참조만 FAIL
if grep -rn 'rules/safety.md' "$SAMPLE" 2>/dev/null | grep -vq '폐지'; then note "no rules/safety.md refs" "FAIL"; fail=1; else note "no rules/safety.md refs" "OK"; fi

# 4) 훅 4종 문법 + 실행권한 + 등록
for h in safety.sh tdd-gate.sh circuit-breaker.sh observe.sh; do
  f="$HOOKS/$h"
  if [ ! -e "$f" ]; then note "hook $h" "FAIL (없음)"; fail=1; continue; fi
  bash -n "$f" 2>/dev/null && s=ok || { s=bad; fail=1; }
  [ -x "$f" ] && x=ok || { x=bad; fail=1; }
  grep -q "$h" "$SAMPLE/.claude/settings.json" && r=ok || { r=bad; fail=1; }
  note "hook $h (syntax/exec/registered)" "$s/$x/$r"
done
# 차단은 exit 2여야 함(훅 한정). 주석 제외.
if sed 's/#.*//' "$HOOKS"/*.sh | grep -qE '\bexit 1\b'; then
  note "no 'exit 1' in hooks" "FAIL (차단은 exit 2)"; fail=1
else note "no 'exit 1' in hooks" "OK"; fi
# 깨진 훅 규약 잔재
if grep -rnE 'TOOL_CMD|TOOL_NAME|TOOL_TARGET' "$SAMPLE/.claude" >/dev/null 2>&1; then
  note "no broken-hook leftovers" "FAIL"; fail=1
else note "no broken-hook leftovers" "OK"; fi

# 5) settings.json/phase.json JSON 유효 + execute.sh 문법/실행권한
jq -e . "$SAMPLE/.claude/settings.json" >/dev/null 2>&1 && note "settings.json valid" "OK" || { note "settings.json valid" "FAIL"; fail=1; }
jq -e . "$SAMPLE/scripts/phase.json" >/dev/null 2>&1 && note "phase.json valid" "OK" || { note "phase.json valid" "FAIL"; fail=1; }
bash -n "$SAMPLE/scripts/execute.sh" 2>/dev/null && note "execute.sh syntax" "OK" || { note "execute.sh syntax" "FAIL"; fail=1; }
[ -x "$SAMPLE/scripts/execute.sh" ] && note "execute.sh executable" "OK" || { note "execute.sh executable" "FAIL"; fail=1; }

# 6) 엔진 승인 게이트: approved=false면 exit 3 (claude 호출 전에 멈춤)
if command -v jq >/dev/null; then
  ( cd "$SAMPLE" && bash scripts/execute.sh >/dev/null 2>&1 ); rc=$?
  [ "$rc" -eq 3 ] && note "engine approval gate (exit 3)" "OK" || { note "engine approval gate (exit 3)" "FAIL (rc=$rc)"; fail=1; }
fi

# 7) 훅 단위 동작 테스트 (실제 픽스처 훅 사용)
if command -v jq >/dev/null; then
  echo '{"tool_input":{"command":"git reset --hard"}}' | bash "$HOOKS/safety.sh" >/dev/null 2>&1; [ $? -eq 2 ] && a=ok || { a=bad; fail=1; }
  echo '{"tool_input":{"command":"./gradlew test"}}'   | bash "$HOOKS/safety.sh" >/dev/null 2>&1; [ $? -eq 0 ] && b=ok || { b=bad; fail=1; }
  note "safety.sh block/pass" "$a/$b"

  tmp="$(mktemp -d)"; mkdir -p "$tmp/scripts"
  echo '{"circuit_breaker":{"tripped":true,"tripped_reason":"t"}}' > "$tmp/scripts/phase.json"
  echo '{"tool_input":{"command":"ls"}}' | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOKS/circuit-breaker.sh" >/dev/null 2>&1; [ $? -eq 2 ] && c=ok || { c=bad; fail=1; }
  echo '{"circuit_breaker":{"tripped":false}}' > "$tmp/scripts/phase.json"
  echo '{"tool_input":{"command":"ls"}}' | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOKS/circuit-breaker.sh" >/dev/null 2>&1; [ $? -eq 0 ] && d=ok || { d=bad; fail=1; }
  note "circuit-breaker.sh trip/pass" "$c/$d"
  rm -rf "$tmp"

  tmp="$(mktemp -d)"; mkdir -p "$tmp/app"
  printf 'class FooTest{}' > "$tmp/app/FooTest.java"
  echo "{\"tool_input\":{\"file_path\":\"$tmp/app/Bar.java\"}}" | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOKS/tdd-gate.sh" >/dev/null 2>&1; [ $? -eq 2 ] && e=ok || { e=bad; fail=1; }
  echo "{\"tool_input\":{\"file_path\":\"$tmp/app/Foo.java\"}}" | CLAUDE_PROJECT_DIR="$tmp" bash "$HOOKS/tdd-gate.sh" >/dev/null 2>&1; [ $? -eq 0 ] && g=ok || { g=bad; fail=1; }
  note "tdd-gate.sh block/pass" "$e/$g"
  rm -rf "$tmp"
fi

echo "----------------------------------------------"
if [ "$fail" -eq 0 ]; then echo "check-sample: PASS"; exit 0
else echo "check-sample: FAIL"; exit 1; fi
