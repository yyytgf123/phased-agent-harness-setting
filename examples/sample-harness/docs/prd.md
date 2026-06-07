# PRD — orders-service

<!-- 산출물: docs/prd.md (SDD 두뇌). 자율 실행의 입력 사양. 밀도가 높을수록 런타임이 안정적이다. -->

## 1. 목표 (한 문단)
orders-service는 커머스 백엔드로, 고객이 주문을 생성하고 외부 PG(payment gateway)를 통해 결제를 처리하며 자신의 주문 내역을 조회할 수 있게 한다. 성공의 정의: 주문 생성→결제 승인→상태 반영이 멱등하고 무결하게 동작하며, p95 응답시간과 결제 정합성 기준을 만족하는 것.

## 2. 사용자 / 시나리오
- 고객(End User) — (1) 장바구니 확정 후 주문 생성, (2) 생성된 주문에 대해 카드 결제 진행, (3) 내 주문 목록/상세 조회
- 내부 운영(Service) — 결제 콜백(webhook) 수신으로 주문 상태 동기화

## 3. 범위 (In Scope)
- 주문 생성 API (`POST /orders`) — 주문 항목·금액 서버측 계산/검증
- 결제 처리 API (`POST /orders/{id}/payments`) — 외부 PG 연동, 멱등성 키, 금액 재검증
- PG 결제 콜백 수신 (`POST /payments/callback`) — 서명 검증 후 주문 상태 전이
- 주문 목록/상세 조회 (`GET /orders`, `GET /orders/{id}`)
- PostgreSQL 영속화 + Flyway 마이그레이션, springdoc OpenAPI 문서

## 4. ## MVP 제외 (Out of Scope) — 명시적 비목표
<!-- AI가 불필요한 확장에 토큰·시간을 낭비하지 않게 막는 가장 강력한 필터. -->
- 환불/취소(refund) 플로우 — 결제 무결성·정산 영향이 커 별도 설계 필요, 이번 MVP에서 제외
- 다중 통화(multi-currency) — 초기엔 단일 통화(KRW) 고정, 환율/정산 복잡도 회피
- 관리자 대시보드(admin dashboard) — 운영 UI는 후속 마일스톤, MVP는 API only
- 부분 결제·할부·포인트 결합 결제 — 단일 전액 카드 결제만 지원

## 5. 기능 요구사항 (테스트 가능하게)
| ID | 요구사항 | 수용 기준(검증 방법) |
|----|----------|----------------------|
| FR-1 | 주문 생성 | 유효한 항목으로 `POST /orders` 호출 시 201과 `orderId` 반환, 서버 계산 금액이 응답에 포함되고 DB에 `PENDING` 상태로 저장된다 (통합 테스트). |
| FR-2 | 결제 처리 | `POST /orders/{id}/payments`를 동일 멱등성 키로 2회 호출하면 PG 호출은 1회만 발생하고 두 응답이 동일하다. 클라이언트 전달 금액≠서버 금액이면 400 (통합 테스트). |
| FR-3 | 결제 콜백 반영 | 유효 서명의 승인 콜백 수신 시 주문이 `PAID`로 전이, 잘못된 서명은 401이며 상태 불변 (통합 테스트). |
| FR-4 | 주문 조회 | `GET /orders`는 요청자 본인 주문만, `GET /orders/{id}`는 존재 시 200/없으면 404를 반환한다 (통합 테스트). |

## 6. 비기능 요구사항
- 성능: 조회 API p95 < 200ms, 결제 생성 p95 < 800ms(PG 왕복 포함)
- 보안: PG 자격증명·시크릿은 코드/이미지에 하드코딩 금지, k8s Secret/환경변수로만 주입. 콜백은 서명 검증 필수
- 가용성: EKS 다중 replica, 무중단 롤링 배포
- 관측성: Prometheus로 요청 지연·에러율·결제 실패율 노출, 결제 실패율 알림 규칙 존재

## 7. 제약·가정
- 기술 제약(헌법 `claude.md`와 일치): Java 21 + Spring Boot, Gradle 빌드, JUnit5, PostgreSQL + Flyway(forward-only), AWS EKS(Terraform+Helm), Prometheus
- 위험 작업(terraform/helm/kubectl apply, flyway migrate, secret)은 plan/dry-run까지만 — 적용은 사람
- 외부 의존: 단일 PG 사업자, 동기 결제 API + 비동기 콜백 제공 가정

## 8. 열린 질문
- PG 사업자/연동 스펙 최종 확정(서명 알고리즘, 멱등성 키 헤더 규격)
- 주문 만료(미결제 PENDING) 정책 — 타임아웃 시간과 자동 취소 여부
- 결제 실패율 알림 임계치(SLO) 수치 확정
