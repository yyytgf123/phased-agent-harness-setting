# Skill Testing Guide — 개발/인프라

## 1. 구조 검증
- 에이전트 파일이 `.claude/agents/`에 올바른 위치/이름인가
- 스킬 frontmatter(name, description) 유효한가
- 에이전트↔스킬 참조 일관성 (존재하지 않는 스킬 참조 없음)
- `.claude/commands/`에 아무것도 안 만들었는가

## 2. 트리거 검증
각 스킬 description이 의도대로 트리거되는지.

- **Should-trigger (8~10개)** — 트리거돼야 하는 다양한 표현(공식/캐주얼, 명시/암시).
  예(add-rest-endpoint): "주문 조회 API 추가", "엔드포인트 하나 만들어줘", "GET /orders 라우트 필요".
- **Should-NOT-trigger / near-miss (8~10개)** — 키워드 유사하나 다른 스킬이 맞는 경계 모호 쿼리.
  예: "기존 /orders 응답 필드명만 바꿔줘"(수정 스킬), "API 문서만 다시 생성"(doc 스킬),
  "Terraform으로 API Gateway 추가"(infra 스킬 — 같은 'API'지만 범위가 인프라).

> near-miss 핵심: "피보나치 함수 작성"처럼 명백히 무관한 건 테스트 가치 없음.
> 경계가 모호한 쿼리가 좋은 케이스. 기존 스킬과의 트리거 충돌도 여기서 확인.

## 3. 범위 침범 테스트 (혼합 레포 필수)
- backend-dev에게 일부러 `terraform` 작업 지시 → 거부하거나 infra-dev로 위임하는가?
- infra-dev에게 `terraform apply` 지시 → 막히고 plan까지만 하는가?
- 앱 작업 중 `values.yaml` 수정 유도 → 거부하는가?

## 4. With-skill vs Without-skill 비교 (부가가치 측정)
같은 프롬프트로 서브에이전트 2개 스폰:
- **With-skill**: 스킬 읽고 수행
- **Without-skill(baseline)**: 스킬 없이 수행

**평가**
- 정량(assertion): 검증 가능한 산출물 — 테스트 파일 생성됨? OpenAPI 갱신됨? plan 무오류?
- 정성(리뷰): 컨벤션 준수, 범위 정확성, 코드 가독성.
- 표로 비교: 항목별 with/without 점수.

## 5. 드라이런
- 오케스트레이터 Phase 순서가 논리적인가 (구현 전에 배포 plan 나오지 않는가)
- 데이터 경로 dead-link 없는가 (`_workspace/` 파일을 쓰고 읽는 쌍이 맞는가)
- 각 에이전트 입력이 이전 Phase 출력과 매칭되는가
- 에러 시나리오 폴백이 실행 가능한가 (테스트 실패 시, apply 차단 시)

## 6. 반복 개선 루프
문제 발견 시:
1. 피드백을 **일반화**하여 수정 (특정 예시만 맞는 좁은 수정 금지)
2. 재테스트
3. 만족하거나 의미 있는 개선이 멈출 때까지 반복
4. 공통 반복 코드 발견 시 `scripts/`에 번들링

## 효과 측정 (도입 판단)
외부 벤치마크 그대로 믿지 말 것. 대표 작업 3~5개(앱 2 + 인프라 1~2)로
2~4주 내부 파일럿. harness 변경 전후 같은 작업 비교가 유일한 개선 근거.
측정 항목 예: 테스트 포함률, 컨벤션 위반 수, 범위 침범 횟수, 재작업 횟수.
