# Skill Writing Guide — 개발/인프라

## 스킬 구조
```
skill-name/
├── SKILL.md (필수)
│   ├── YAML frontmatter (name, description 필수)
│   └── Markdown 본문
└── (선택)
    ├── scripts/      - 반복/결정적 작업 실행 코드 (로딩 없이 실행)
    ├── references/   - 조건부 로딩 참조 문서
    └── assets/       - 템플릿/설정 샘플
```

## Description — 적극적(pushy) 트리거
description은 스킬의 **유일한 트리거 메커니즘**. Claude는 보수적으로 트리거하므로 적극적으로 쓴다.

- 나쁨: `"엔드포인트 추가 스킬"`
- 좋음: `"신규 REST 엔드포인트 추가 시 컨트롤러·서비스·DTO·테스트·OpenAPI를 함께 생성/갱신한다. 새 API/라우트/엔드포인트 추가를 언급하면 반드시 이 스킬 사용. app/ 범위 전용. 기존 엔드포인트 단순 수정만이면 트리거하지 않음."`

핵심: 하는 일 + 구체적 트리거 상황 + **near-miss 구분**(언제 트리거 안 하는지) 모두 명시.

## 본문 작성 원칙

| 원칙 | 설명 |
|------|------|
| **Why를 설명** | "NEVER apply" 대신 "apply는 prod 상태를 즉시 바꿔 롤백이 어렵다. 그래서 plan까지만." 이유를 알면 엣지 케이스도 옳게 판단. |
| **Lean** | 본문 500줄 이내. 무게 못 버는 내용은 references/로. 컨텍스트는 공공재. |
| **일반화** | 특정 예시에 오버피팅 금지. 원리를 설명해 다양한 입력 대응. |
| **반복 코드 번들링** | 공통 헬퍼(테스트 스캐폴드, plan 파서)는 scripts/에 미리. |
| **명령형** | "~한다/~하라" 어조. |

## Progressive Disclosure (3단계 로딩)
원칙은 `_shared/design-principles.md` §6. 스킬에 적용하면:

| 단계 | 시점 | 크기 |
|------|------|------|
| Metadata (name+description) | 항상 | ~100단어 |
| SKILL.md 본문 | 트리거 시 | <500줄 |
| references/ | 필요 시 | 무제한 |

**크기 관리**
- 500줄 근접 → 세부를 references/로 분리, 본문에 "언제 읽으라" 포인터.
- 300줄+ reference는 상단에 목차(ToC).
- **도구별 변형은 references/ 하위로 분리** → 관련 파일만 로드:
```
deploy/
├── SKILL.md (워크플로 + 선택 가이드)
└── references/
    ├── aws.md      ← AWS일 때만 로드
    ├── gcp.md
    └── azure.md
```
앱도 동일: `references/gradle.md`, `maven.md` 식으로.

## 스킬-에이전트 연결
- 에이전트 1 ↔ 스킬 1~N. 공유 스킬도 가능.
- 스킬 = "어떻게", 에이전트 = "누가".

## 개발/인프라 스킬 본문 필수 요소
1. **범위 명시** — 수정 가능 디렉터리 + 절대 금지 범위.
2. **단계별 검증 명령** — 각 단계 끝에 스택 실제 명령 (tooling-matrix 참조).
3. **완료 정의** — 무엇을 실행해 무엇을 확인하면 done.
4. **위험 작업 처리** — `_shared/safety-rules.md` 적용(apply/migrate/secret은 plan/dry-run까지 + 승인 문구).

## 데이터 스키마 표준
산출물이 검증 가능하면 스키마를 박는다. 예: API 변경 스킬은
"변경된 엔드포인트 목록 + 요청/응답 shape"을 `_workspace/`에 JSON으로 남겨 qa가 교차검증.
