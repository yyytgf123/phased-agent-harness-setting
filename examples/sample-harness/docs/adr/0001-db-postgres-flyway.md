# ADR-0001: PostgreSQL + Flyway forward-only 마이그레이션

<!-- 산출물: docs/adr/0001-db-postgres-flyway.md. 결정 1개당 파일 1개. why + 트레이드오프를 남긴다. -->

- 상태: Accepted
- 날짜: 2026-06-07
- 관련: PRD FR-1·FR-2·FR-3 / architecture §3(데이터 모델)

## 맥락 (Context)
orders-service는 주문·결제처럼 금액과 상태 전이의 무결성이 중요한 데이터를 다룬다. 트랜잭션·제약조건·동시성 제어가 견고한 관계형 저장소와, 팀이 협업하며 스키마를 안전하게 진화시킬 버전 관리된 마이그레이션 도구가 필요했다. 위험 작업(실제 마이그레이션 실행)은 비가역적이므로 작성과 적용을 분리할 수 있어야 한다.

## 결정 (Decision)
저장소로 PostgreSQL을 채택하고, 스키마 변경은 Flyway의 forward-only(전진 전용) 버전 마이그레이션(`V{n}__.sql`)으로 관리한다.

## 근거 (Why)
- PostgreSQL: 강한 트랜잭션·제약조건·인덱스, 결제/주문 무결성에 적합하며 EKS/RDS 운영 친화적.
- Flyway: 단순한 SQL 기반·버전 순차 적용으로 학습비용이 낮고 Spring Boot/Gradle 통합이 자연스럽다.
- forward-only: 적용된 마이그레이션을 절대 수정하지 않고 새 버전만 추가 → 환경 간 드리프트와 "되돌리기"로 인한 데이터 손상 위험을 구조적으로 차단. 파괴적 변경은 다단계(추가→이행→제거)로 분리.

## 고려한 대안 (Alternatives)
| 대안 | 장점 | 단점 / 기각 이유 |
|------|------|------------------|
| Raw SQL 스크립트 수동 관리 | 의존성 0, 완전한 자유 | 버전 추적·적용 이력·검증 부재 → 환경 드리프트와 휴먼에러 위험 |
| Liquibase | XML/YAML 변경셋, 자동 롤백, 풍부한 추상화 | 추상화·DSL 학습비용, SQL 가시성 저하. MVP 규모에 과함 |
| ORM 자동 DDL(`ddl-auto=update`) | 초기 속도 빠름 | 프로덕션에서 비결정적·비가역, 무결성 위험 → 금지 |

## 트레이드오프 / 결과 (Consequences)
- 얻는 것: 버전화된 안전한 스키마 진화, `flyway validate`로 사전 검증, 협업 시 일관성
- 포기/감수: 자동 롤백 없음 — 되돌림은 항상 새 전진 마이그레이션으로(복원 부담은 다단계 설계로 완화)
- 후속 영향: db-migration-dev는 작성·`flyway validate`/`info`까지만 수행하고 `flyway migrate` 실행은 사람이 담당(루트 `claude.md` `# CRITICAL — Safety`)
