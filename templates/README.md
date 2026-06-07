# templates — 산출물 골격

Claude Code가 **복사·치환해서 프로젝트에 구축하는** 골격 모음.
phase 폴더(지침·지식)와 분리해 여기 모았다. 사용자가 채우는 파일이 아니다.

| 템플릿 | 어느 Phase에서 | 무엇으로 구축되나 |
|--------|----------------|-------------------|
| `CLAUDE.md.tmpl` | Phase 3 | 프로젝트 루트 `CLAUDE.md` (맵, 60줄 이하) |
| `AGENT.md.tmpl`  | Phase 3 | `프로젝트/.claude/agents/{name}.md` |
| `SKILL.md.tmpl`  | Phase 4 | `프로젝트/.claude/skills/{name}/SKILL.md` |

## 흐름
```
phase 폴더(README + 상세 md)  ──읽고──▶  templates/*.tmpl  ──떠서──▶  프로젝트/.claude/*
        (지침·지식)                        (골격)                  (최종 산출물)
```

각 템플릿의 `<...>` 자리는 Claude Code가 Phase 진행 중 스택·도메인·탐색 결과로 채운다.
