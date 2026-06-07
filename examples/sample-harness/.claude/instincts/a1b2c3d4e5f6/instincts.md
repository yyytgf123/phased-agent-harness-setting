# Instincts — a1b2c3d4e5f6

<!-- 산출물: .claude/instincts/<project-hash>/instincts.md (점수 매긴 패턴 = 승격 후보 풀).
     raw/observations.log(훅 append)을 점수 있는 패턴으로 올린 것. 한 줄 = 한 패턴.
     점수 의미(0.3~0.9)·상승/하락 규칙은 phase7/instinct-format.md 참조. -->

## Patterns
[score=0.7] domain=testing :: 엔드포인트 추가 후 ./gradlew test 를 항상 실행함 :: seen=5 last=2026-06-07
[score=0.5] domain=iac :: rds 모듈 수정 시 terraform plan 까지만 돌림(apply는 사람 승인) :: seen=2 last=2026-06-07
