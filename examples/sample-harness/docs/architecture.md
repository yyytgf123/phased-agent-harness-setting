# Architecture (설계 의도) — orders-service

> 최종 갱신: 2026-06-07. SDD 설계서 + 하단 Harness 구조 스냅샷.

## 1. 시스템 개요
주문/결제 백엔드(Spring Boot)와 AWS EKS 인프라(Terraform/Helm)가 한 레포에 있다.
```
client → API(app/) → service → repository → PostgreSQL
                       │
                  PaymentService → 외부 PG(래퍼 경유)
app/ ↔ infra/(EKS, Terraform, Helm) ↔ monitoring/(Prometheus)
```

## 2. 컴포넌트 / 경계
| 컴포넌트 | 책임 | 위치 | 의존 |
|----------|------|------|------|
| Order API | 주문 CRUD/조회 | `app/.../api` | DB |
| PaymentService | 외부 PG 결제 | `app/.../payment` | PG 래퍼 |
| Infra | EKS 프로비저닝/배포 | `infra/` | AWS |
| Monitoring | 메트릭/알림 | `monitoring/` | Prometheus |

## 3. 데이터 모델 (핵심)
Order(1)–(N)OrderItem, Payment(1)–(1)Order. 스키마 변경은 add-db-migration(Flyway forward-only).

## 4. 핵심 결정 (요약 → 상세 ADR)
- PostgreSQL + Flyway forward-only → `docs/adr/0001-db-postgres-flyway.md`
- AWS EKS + Terraform + Helm → `docs/adr/0002-eks-terraform-helm.md`

## 5. 경계면 계약 (cross-boundary, QA 근거)
- API ↔ DTO: 컨트롤러는 DTO만 반환(Entity 직접 반환 금지).
- app env ↔ helm values: 환경변수 키 일치. tf output ↔ app config: RDS 엔드포인트 주입.
- Flyway migration ↔ Entity: 컬럼/제약 일치.

## 6. 위험·완화
- 결제 모듈 prod 영향 → reviewer + security-reviewer 게이트. PG 호출은 래퍼로 한정.

---
<!-- 아래는 하네스 구조 스냅샷(부분 편집으로만 갱신 — kb/architecture-doc.md). -->
## Harness 구조 스냅샷

### Agents
| 에이전트 | 범위 | 타입 | 연결 스킬 |
|----------|------|------|-----------|
| backend-dev | app/ | general-purpose | add-rest-endpoint, write-integration-test, fix-bug-with-test |
| infra-dev | infra/, monitoring/ | general-purpose | add-terraform-module |
| db-migration-dev | db/, migrations/ | general-purpose | add-db-migration |
| reviewer | 전체읽기 | general-purpose | — |
| security-reviewer | 전체읽기 | general-purpose | — |
| qa | 전체읽기 | general-purpose | cross-boundary-check |

### Skills
| 스킬 | 범위 | 한 줄 |
|------|------|-------|
| add-rest-endpoint | app | 컨트롤러·서비스·DTO·테스트·OpenAPI (TDD) |
| write-integration-test | app | 기존 코드 통합/e2e 테스트 보강 |
| fix-bug-with-test | app | 재현 실패 테스트 우선 → 픽스 → 회귀 |
| add-db-migration | infra/app | Flyway forward-only + 롤백 노트 |
| add-terraform-module | infra | 모듈·변수·출력·plan 검증 |
| cross-boundary-check | infra | 경계면 교차 검증(읽기 전용) |

### Engine / Hooks / Data Flow
- 엔진: `scripts/execute.sh` + `scripts/phase.json`(승인 게이트 + 테스트 게이트 + 서킷브레이커).
- 커맨드: `/harness`(단계 분할) · `/review`(검증·강화).
- 훅: safety(차단) · tdd-gate(테스트 없는 구현 차단) · circuit-breaker(트립 정지) · observe(관찰).
- 데이터: docs/work_orders → 에이전트 → _workspace/ → 코드 + docs/result_report/.
