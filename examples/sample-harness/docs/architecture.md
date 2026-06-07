# Architecture — orders-service

> 최종 갱신: 2026-06-07 (작업: 초기 하네스 구축)

## Agents
| 에이전트 | 범위 | 타입 | 연결 스킬 |
|----------|------|------|-----------|
| backend-dev | app/ | general-purpose | add-rest-endpoint |
| infra-dev   | infra/, monitoring/ | general-purpose | add-terraform-module |

## Skills
| 스킬 | 소유 에이전트 | 범위 | 한 줄 설명 |
|------|---------------|------|-----------|
| add-rest-endpoint | backend-dev | app | 컨트롤러·서비스·DTO·테스트·OpenAPI 생성 |
| add-terraform-module | infra-dev | infra | 모듈·변수·출력·plan 검증 구성 |

## Orchestrator
- 실행 모드: 서브
- 패턴: 생성-검증
- 데이터 경로: _workspace/{phase}_{agent}_{artifact}

## Hooks
| Hook | 시점 | 무엇을 강제 |
|------|------|-------------|
| safety  | PreToolUse | 시크릿 커밋 차단 |
| observe | Pre/PostToolUse | 패턴 관찰 |

## Data Flow
- 입력: docs/work_orders/ → 에이전트
- 중간: _workspace/02_backend-dev_diff.md
- 출력: 코드 + docs/result_report/
