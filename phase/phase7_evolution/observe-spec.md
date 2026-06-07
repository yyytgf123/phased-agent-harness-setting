# Observe Spec — 관찰 Hook 명세

도구 사용을 100% 결정적으로 캡처하는 Hook. LLM 호출 없이 가벼운 셸로 처리한다.

## 설치 (`.claude/settings.json`)
```json
{
  "hooks": {
    "PreToolUse":  [{ "matcher": "*", "hooks": [{ "type": "command", "command": ".claude/hooks/observe.sh pre" }] }],
    "PostToolUse": [{ "matcher": "*", "hooks": [{ "type": "command", "command": ".claude/hooks/observe.sh post" }] }]
  }
}
```
> matcher "*"는 모든 도구를 관찰. 안전 차단용 Hook(safety-rules)과는 별개 파일로 둔다.

## observe.sh (개념 골격)
```bash
#!/bin/bash
# $1 = pre|post. 도구명/인자는 환경변수/stdin으로 전달됨(런타임 규약 확인 필요).
PHASE="$1"
PROJECT_HASH=$(git config --get remote.origin.url 2>/dev/null | sha1sum | cut -c1-12)
[ -z "$PROJECT_HASH" ] && PROJECT_HASH="no-remote"
DIR=".claude/instincts/$PROJECT_HASH/raw"
mkdir -p "$DIR"

# 1) 입력 수집 (런타임이 주는 도구명·인자·경로)
RECORD="$(date -u +%FT%TZ)|$PHASE|$TOOL_NAME|$TOOL_TARGET"

# 2) 민감정보 redact (절대 raw로 남기지 않음)
RECORD=$(echo "$RECORD" | sed -E 's/(api[_-]?key|secret|token|password)=[^ ]*/\1=[REDACTED]/Ig')
case "$TOOL_TARGET" in
  *.env|*-prod.*|*tfstate*|*kubeconfig*|*.pem) RECORD="${RECORD%%|*}|$PHASE|<sensitive-redacted>";;
esac

# 3) append-only 기록
echo "$RECORD" >> "$DIR/observations.log"
exit 0   # 관찰은 절대 작업을 막지 않는다 (차단은 safety Hook 담당)
```

## 캡처 항목 (raw observation)
| 필드 | 예 |
|------|-----|
| timestamp | 2026-06-07T09:00:00Z |
| phase | pre / post |
| tool | Edit / Bash / Read |
| target | app/.../OrderController.java / `./gradlew test` |
| (post) outcome | ok / error (가능하면) |

## 원칙
- **관찰은 차단하지 않는다.** 항상 `exit 0`. 위험 명령 차단은 safety-rules의 Hook이 담당.
- **민감정보는 raw에도 남기지 않는다.** secret/PII/prod 파일 경로는 즉시 redact.
- **LLM 호출 없음.** 관찰은 셸로만. 비용·지연 최소화.
- 저장은 `.claude/instincts/<project-hash>/raw/observations.log` (프로젝트 격리).

> raw 관찰을 점수 있는 instinct로 올리는 규칙은 `instinct-format.md` 참조.
> 런타임이 도구명/인자를 어떤 변수로 주는지는 Claude Code 버전마다 다를 수 있으니
> 설치 시 현재 Hook 입력 규약을 docs에서 확인할 것.
