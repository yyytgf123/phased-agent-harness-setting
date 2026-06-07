# Observe Spec — 관찰 Hook 명세

도구 사용을 100% 결정적으로 캡처하는 Hook. LLM 호출 없이 가벼운 셸로 처리한다.

## 설치 골격
- `.claude/settings.json` (observe hook 등록): `../../templates/settings.json.tmpl`. matcher "*"로 모든 도구 관찰,
  안전 차단 Hook(safety)과는 별개 파일.
- `.claude/hooks/observe.sh` (캡처 스크립트): `../../templates/hooks/observe.sh.tmpl`.
  project-hash 스코핑 + redact + append-only.

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
> Hook 입력은 **stdin JSON**으로 들어온다(`.tool_name`, `.tool_input.command`/`.file_path`). jq로 파싱.
> 환경변수는 `CLAUDE_PROJECT_DIR` 등만 제공되며 도구명/인자는 stdin으로만 받는다.
