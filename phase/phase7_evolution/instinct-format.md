# Instinct Format — 패턴 저장 포맷 + 신뢰도 운영

raw 관찰(`observe-spec.md`)을 점수 있는 instinct로 올리는 규칙.

## 저장 위치 (프로젝트 격리)
```
.claude/instincts/<project-hash>/
├── raw/observations.log     # 훅이 append (사람이 안 건드림)
└── instincts.md             # 점수 매긴 패턴 (승격 후보 풀)
```
project-hash는 git remote URL 해시. remote 없으면 `no-remote`. A 프로젝트 패턴이 B로
새지 않게 레포 단위로 격리한다.

## instinct 한 줄 포맷 (파싱 쉽게 고정)
`instincts.md` 골격은 `../../templates/instincts.md.tmpl`. 한 줄 = `[score=N] domain=tag :: 서술 :: seen=N last=날짜`.
- domain 태그: code-style / testing / git / iac / k8s / security / review
- seen: 재관찰 횟수 (자동 카운트 가능). last: 마지막 관찰일.

## 신뢰도 점수 (0.3~0.9)
| 점수 | 의미 | 동작 |
|------|------|------|
| 0.3 | 잠정 | 제안만, 강제 안 함 |
| 0.5 | 보통 | 관련 시 적용 |
| 0.7 | 강함 | CLAUDE.md/스킬 승격 후보 |
| 0.9 | 거의 확실 | 핵심 규칙·Hook 강제 대상 |

- **상승**: 같은 패턴 반복 관찰 / 사용자가 안 고침 / 다른 출처와 일치.
- **하락**: 사용자가 명시적으로 수정 / 오래 미관찰 / 반증 등장.

> 점수는 사람이 매기는 보조 지표다. seen은 자동이지만, 최종 승격 판단은 사람이 한다.
> 자동 승격을 과신하지 말 것. 승격·정리 리듬은 `evolution-guide.md` 참조.
