---
name: add-rest-endpoint
description: >
  신규 REST 엔드포인트 추가 시 Spring 컨트롤러·서비스·DTO·통합테스트·springdoc OpenAPI를 함께 생성/갱신한다.
  "새 API/라우트/엔드포인트 추가"를 언급하면 반드시 사용하라. app/ 범위 전용이며 테스트를 먼저 쓴다.
  near-miss: 기존 엔드포인트 로직만 손보는 작업이면 이 스킬을 트리거하지 말 것(일반 수정/fix-bug-with-test로).
scope: app
---

# 신규 REST 엔드포인트 추가

## 언제 쓰나 / 안 쓰나
- 트리거: 새 API 경로 추가(예: `POST /orders`, `POST /orders/{id}/payments`), 새 리소스 CRUD, 새 핸들러/라우트 신설
- 비트리거(near-miss): 기존 엔드포인트 내부 로직만 수정 → 일반 수정 또는 fix-bug-with-test

## 범위 제약
- 수정 가능: `app/` 만
- 절대 금지: 다른 범위(`infra/`, `monitoring/` 등) 수정, Flyway 마이그레이션 직접 작성(→ db-migration-dev)

## 절차

### Step 1 — 실패 테스트 먼저 (TDD)
유사 `@RestController` 패턴을 확인하고, 새 엔드포인트의 계약을 검증하는 `@SpringBootTest`/`MockMvc` 통합 테스트를 **먼저 작성한다**(아직 실패해야 정상).
- 검증: `./gradlew test --tests '*OrderControllerTest'` (RED 확인)

### Step 2 — 구현
컨트롤러·서비스·DTO를 레포 기존 패턴대로 생성. DTO와 Entity는 분리하고 Entity를 직접 반환하지 않는다. 결제 연동 엔드포인트면 금액 서버측 검증·멱등성 키를 포함한다.
- 검증: `./gradlew compileJava`

### Step 3 — 테스트 통과 + 문서
테스트가 GREEN이 될 때까지 구현. springdoc 어노테이션(`@Operation`/`@Schema`)으로 OpenAPI 스펙을 갱신.
- 검증: `./gradlew test --tests '*OrderControllerTest'`

### Step 4 — 완료 검증 (필수)
- [ ] `./gradlew test` 통과
- [ ] 범위 밖 파일 수정 없음
- [ ] OpenAPI(springdoc) 갱신, DTO/Entity 분리 유지
- [ ] (해당 시) `_workspace/`에 산출물 스키마 기록 → qa 교차검증용

## 위험 작업 처리 (해당 시)
- apply/migrate/secret은 plan/dry-run까지만. 전체 금지목록·표준 응답은 루트 헌법 `claude.md`의 `# CRITICAL — Safety` 참조(복붙 금지).
