#!/usr/bin/env bash
# scripts/execute.sh (step6 산출물) — 자율 phase 실행 엔진 (bash+jq). 사용: bash scripts/execute.sh
# phase.json의 phases[]를 의존성 순으로 headless `claude -p`로 실행 + phase별 test_cmd 게이트 + 서킷브레이커.
# 안전: 사람 승인(approved) + 서킷브레이커 + phase별 타임아웃. phase.json은 이 스크립트만 쓴다.
set -uo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE="$ROOT/scripts/phase.json"
command -v jq >/dev/null || { echo "execute.sh: jq 필요(brew install jq)"; exit 4; }
[ -f "$STATE" ] || { echo "execute.sh: $STATE 없음. 먼저 /harness로 단계 분할을 만드세요."; exit 4; }

jqi() { local tmp; tmp="$(mktemp)"; jq "$@" "$STATE" >"$tmp" && mv "$tmp" "$STATE"; }

run_timeout() {
  local secs="$1"; shift
  if command -v gtimeout >/dev/null; then gtimeout "${secs}s" "$@"; return $?; fi
  if command -v timeout  >/dev/null; then timeout  "${secs}s" "$@"; return $?; fi
  "$@" & local pid=$!
  ( sleep "$secs"; kill -0 "$pid" 2>/dev/null && kill "$pid" 2>/dev/null ) & local watcher=$!
  wait "$pid"; local rc=$?
  kill "$watcher" 2>/dev/null
  return $rc
}

record_error() {
  local id="$1" msg="$2"
  jqi --arg id "$id" --arg m "$msg" '
    (.phases[] | select(.id==$id)) |=
      (.attempts += 1 | .last_error=$m | .status=(if .attempts>=2 then "failed" else "pending" end))
    | .circuit_breaker.consecutive_errors += 1'
  local ce mx; ce=$(jq -r '.circuit_breaker.consecutive_errors' "$STATE"); mx=$(jq -r '.circuit_breaker.max_consecutive_errors' "$STATE")
  if [ "$ce" -ge "$mx" ]; then
    jqi --arg m "$msg" '.circuit_breaker.tripped=true | .circuit_breaker.tripped_reason=("연속 \(.circuit_breaker.consecutive_errors)회 실패: "+$m)'
  fi
}

[ "$(jq -r '.approved' "$STATE")" = "true" ] || {
  echo "phase.json이 아직 승인되지 않았습니다(approved=false)."
  echo "→ /harness 결과(phases[])를 검토하고, 이상 없으면 approved=true 로 바꾼 뒤 다시 실행하세요."
  exit 3
}

TIMEOUT=$(jq -r '.session.per_phase_timeout_sec // 1800' "$STATE")
MODEL=$(jq -r '.session.model // "opus"' "$STATE")
MAXRUN=$(jq -r '.session.max_phases_per_run // empty' "$STATE")
ran=0

while :; do
  if [ "$(jq -r '.circuit_breaker.tripped' "$STATE")" = "true" ]; then
    echo "🛑 서킷브레이커 정지: $(jq -r '.circuit_breaker.tripped_reason' "$STATE")"; exit 2
  fi
  if [ -n "$MAXRUN" ] && [ "$ran" -ge "$MAXRUN" ]; then
    echo "⏸ max_phases_per_run($MAXRUN) 도달 — 이번 실행 종료."; exit 0
  fi

  DONE_JSON=$(jq -c '[.phases[]|select(.status=="done")|.id]' "$STATE")
  PID=$(jq -r --argjson done "$DONE_JSON" '
    [ .phases[] | select(.status=="pending")
      | select( ([.depends_on[]] - $done) | length == 0 ) ] | .[0].id // empty' "$STATE")

  if [ -z "$PID" ]; then
    REMAIN=$(jq -r '[.phases[]|select(.status!="done")]|length' "$STATE")
    [ "$REMAIN" = "0" ] && { echo "✅ 모든 phase 완료."; exit 0; }
    echo "⚠️ 실행 가능한 pending phase 없음(미완 $REMAIN개). phase.json 점검 필요."; exit 1
  fi

  TITLE=$(jq -r --arg id "$PID" '.phases[]|select(.id==$id).title' "$STATE")
  TCMD=$(jq -r --arg id "$PID" '.phases[]|select(.id==$id).test_cmd // empty' "$STATE")
  echo "=== ▶ $PID: $TITLE ==="
  jqi --arg id "$PID" '(.phases[]|select(.id==$id).status)="running" | .current=$id'

  PROMPT=$(cat <<EOF
너는 승인된 계획의 phase "$PID"($TITLE) 하나만 수행한다.
- 먼저 scripts/phase.json 을 읽어 이 phase의 deliverables·test_cmd·depends_on을 확인하라.
- 헌법 claude.md(# CRITICAL 규칙 최우선)와 설계 docs/architecture.md·docs/prd.md를 따른다.
- TDD: 실패하는 테스트를 먼저 쓰고, '$TCMD' 가 통과할 때까지 구현하라.
- 이 phase의 deliverables 외 다른 phase 파일은 건드리지 마라. phase.json은 수정하지 마라(읽기 전용).
- 끝나면 deliverables가 존재하고 테스트가 통과하는 상태로 종료하라.
EOF
)
  if ! run_timeout "$TIMEOUT" claude -p "$PROMPT" \
        --add-dir "$ROOT" \
        --permission-mode acceptEdits \
        --model "$MODEL" \
        --settings "$ROOT/.claude/settings.json" \
        --output-format json > "$ROOT/scripts/.last_session.json" 2>>"$ROOT/scripts/.execute.log"; then
    echo "  ✗ 세션 실패/타임아웃"; record_error "$PID" "session timeout/error"; ran=$((ran+1)); continue
  fi

  if [ -n "$TCMD" ]; then
    jqi --arg id "$PID" '(.phases[]|select(.id==$id).status)="testing"'
    echo "  • 테스트: $TCMD"
    if ( cd "$ROOT" && eval "$TCMD" ); then
      jqi --arg id "$PID" --arg ts "$(date -u +%FT%TZ)" \
        '(.phases[]|select(.id==$id)) |= (.status="done"|.attempts+=1|.test={ran:true,passed:true,ts:$ts}) | .circuit_breaker.consecutive_errors=0'
      echo "  ✓ $PID 완료"
    else
      echo "  ✗ 테스트 실패"; record_error "$PID" "test failed: $TCMD"
    fi
  else
    jqi --arg id "$PID" --arg ts "$(date -u +%FT%TZ)" \
      '(.phases[]|select(.id==$id)) |= (.status="done"|.attempts+=1|.test={ran:false,passed:true,ts:$ts}) | .circuit_breaker.consecutive_errors=0'
    echo "  ✓ $PID 완료(테스트 없음)"
  fi
  ran=$((ran+1))
done
