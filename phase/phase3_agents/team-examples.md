# Team Examples — 개발/인프라 실전 구성

실제로 바로 쓸 수 있는 팀 구성 3종. 각 구성은 에이전트 + 스킬 + 패턴 조합.

---

## 예시 1: 혼합 레포 기능 개발 (생성-검증)

**상황:** Spring 백엔드 + Terraform 인프라가 한 레포. 신규 기능에 앱 변경 + 인프라 변경 동반.

**팀 (4명, 생성-검증 + 파이프라인)**
| 에이전트 | 범위 | 스킬 |
|----------|------|------|
| backend-dev | app/ | add-rest-endpoint, write-integration-test |
| infra-dev | infra/, monitoring/ | add-terraform-module, add-alert-rule |
| qa | 전체(general-purpose) | cross-boundary-check |
| reviewer | 전체 읽기 | (스킬 없음, 게이트 역할) |

**흐름 (파이프라인 + 게이트)**
```
1. backend-dev: 엔드포인트 구현 + 테스트 (app/)
2. infra-dev: 필요 리소스 모듈 + plan (infra/)  [1과 병렬 가능]
3. qa: API 응답 shape ↔ 클라이언트/스키마 교차 비교 (각 모듈 완성 직후)
4. reviewer: 보안·범위침범·컨벤션 게이트 → 통과 전 완료 금지
```

---

## 예시 2: 코드 리뷰 & 리팩터링 (팬아웃/팬인)

**상황:** PR 전체를 다각도로 점검.

**팀 (4명, 팬아웃/팬인)**
| 에이전트 | 점검 영역 |
|----------|-----------|
| arch-reviewer | 아키텍처·계층 위반·결합도 |
| security-reviewer | OWASP Top 10, 시크릿 하드코딩, 권한 |
| perf-reviewer | N+1 쿼리, 불필요 할당, 동기/비동기 |
| style-reviewer | 컨벤션, 네이밍, 린트 |

**흐름**
```
[supervisor] ─팬아웃→ 4명 병렬 점검 ─팬인→ 단일 리포트로 취합
            (상충 의견은 삭제 말고 출처 병기)
```

---

## 예시 3: 인프라 전용 — 배포 파이프라인 변경 (파이프라인)

**상황:** k8s 매니페스트 + Helm + 알림 룰 변경. prod 영향 큼 → 안전 게이트 강함.

**팀 (3명, 파이프라인 + 강한 게이트)**
| 에이전트 | 범위 | 금지 |
|----------|------|------|
| iac-dev | terraform/ | terraform apply |
| k8s-dev | k8s/, helm/ | kubectl apply (dry-run까지만) |
| infra-reviewer | 전체 읽기 | — (plan/diff 결과로 게이트) |

**흐름**
```
1. iac-dev: terraform plan 산출 → _workspace/plan.txt
2. k8s-dev: helm template / kubectl --dry-run=client → _workspace/diff.txt
3. infra-reviewer: plan·diff 검토 → 위험요소 보고
4. [사람] plan/diff 확인 후 직접 apply  ← AI는 여기서 멈춤
```

> 공통: 모든 위험 작업은 plan/dry-run까지만. apply·migrate·secret 접근은 사람 승인.
> 정의 파일 골격은 templates/AGENT.md.tmpl, 안전 규칙은 templates/safety-rules.md.
