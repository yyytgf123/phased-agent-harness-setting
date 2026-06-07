# Phase 7 — 지속 개선 / 진화 (Evolution)

## 이 단계는 무엇을 하나
하네스를 한 번 만들고 끝내지 않는다. 실사용에서 **에이전트의 행동 패턴을 관찰·축적하고,
검증된 패턴을 규칙·스킬로 승격**하는 자체 학습 루프를 구축한다.
외부 도구(ECC 등) 없이 **markdown + 가벼운 Hook 스크립트**로 자급자족한다.

> 사상은 "관찰 → 점수화 → 승격 → 정리"의 4박자다. 수동 Bug Log(`_shared/design-principles.md`)가
> 이 루프의 0단계라면, Phase 7은 그것을 반자동으로 끌어올린 것이다.

## 4박자 루프
```
관찰(Observe)  ──▶  축적(Instinct)  ──▶  승격(Evolve)  ──▶  정리(Prune)
 Hook 100%캡처      점수+도메인 태그      검증된 것만 규칙/스킬화    낮은 점수·만료 제거
```

## 읽을 상세 (이 폴더)
| 파일 | 무엇을 담음 |
|------|-------------|
| `evolution-guide.md` | 4박자 루프 전체 운영법 + 주간 리듬 |
| `observe-spec.md` | 관찰 Hook(PreToolUse/PostToolUse) 명세 + 캡처 포맷 |
| `instinct-format.md` | 패턴 저장 포맷 + 신뢰도 점수(0.3~0.9) 운영 규칙 |

## 쓸 템플릿 (`../../templates/`)
| 템플릿 | 구축 결과 |
|--------|-----------|
| `hooks/observe.sh.tmpl` · `settings.json.tmpl` | `.claude/hooks/observe.sh` + settings.json observe hook |
| `instincts.md.tmpl` | `.claude/instincts/<hash>/instincts.md` (승격 후보 풀) |

## 구축 절차
1. `observe-spec.md`대로 관찰 Hook을 `.claude/settings.json` + `.claude/hooks/observe.sh`에 설치.
2. 관찰 산출물은 `.claude/instincts/<project-hash>/`에 저장 (`instinct-format.md` 포맷).
3. 주 1회 `evolution-guide.md`의 리듬대로: 점수 갱신 → 0.7↑ 묶음 승격 → 0.3↓·만료 정리.
4. 승격된 규칙은 Phase 3(CLAUDE.md)·스킬은 Phase 4(.claude/skills) 형식으로 반영.

## 입력 / 출력
- 입력: Phase 1~6으로 구축·가동 중인 하네스 + 실사용 세션
- 출력: 갱신된 CLAUDE.md 규칙 / 새 스킬 / 정리된 instinct 저장소

## 게이트 (품질 핵심)
- 신뢰도 0.3은 "제안만", 0.7↑만 자동 적용. 초기 저점수 패턴을 규칙으로 굳히지 말 것.
- 프로젝트 격리: instinct는 project-hash로 스코핑. 글로벌 승격은 신중히(여러 프로젝트에서 검증된 것만).
- 관찰이 민감정보(secret/PII)를 캡처하지 않도록 redact (`observe-spec.md` 참조).
