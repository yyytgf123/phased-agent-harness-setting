#!/bin/bash
# .claude/hooks/observe.sh (Phase 7 산출물) — 도구 사용을 100% 결정적으로 캡처. LLM 호출 없음. 항상 exit 0(비차단).
# $1 = pre|post. 입력은 stdin JSON(.tool_name / .tool_input.command|.file_path). 명세: phase7/observe-spec.md.
PHASE="$1"
command -v jq >/dev/null || exit 0   # jq 없으면 관찰 스킵(작업은 막지 않음)
INPUT=$(cat)
PROJECT_HASH=$(git config --get remote.origin.url 2>/dev/null | shasum | cut -c1-12)
[ -z "$PROJECT_HASH" ] && PROJECT_HASH="no-remote"
DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/instincts/$PROJECT_HASH/raw"
mkdir -p "$DIR"

# 1) 입력 수집 (stdin JSON에서 도구명·인자·경로)
TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty')
TARGET=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // .tool_input.file_path // empty')
RECORD="$(date -u +%FT%TZ)|$PHASE|$TOOL|$TARGET"

# 2) 민감정보 redact (절대 raw로 남기지 않음)
RECORD=$(printf '%s' "$RECORD" | sed -E 's/(api[_-]?key|secret|token|password)=[^ ]*/\1=[REDACTED]/Ig')
case "$TARGET" in
  *.env|*-prod.*|*tfstate*|*kubeconfig*|*.pem) RECORD="${RECORD%%|*}|$PHASE|<sensitive-redacted>";;
esac

# 3) append-only 기록
echo "$RECORD" >> "$DIR/observations.log"
exit 0   # 관찰은 절대 작업을 막지 않는다 (차단은 safety.sh 담당)
