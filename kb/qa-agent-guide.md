# QA Agent Guide — 개발/인프라

빌드 하네스에 QA 에이전트를 포함할 때 참조. 통합 정합성 검증·경계면 버그 패턴·정의 템플릿.

## 핵심 원칙
- **타입은 general-purpose 필수** — Explore는 읽기전용이라 검증 스크립트 실행 불가.
- QA의 본질은 **"존재 확인"이 아니라 "경계면 교차 비교"** — 두 쪽을 동시에 읽고 shape을 맞춘다.
- **incremental QA** — 전체 완성 후 1회가 아니라, **각 모듈 완성 직후 점진 실행**. 늦게 발견할수록 비싸다.

## 경계면 버그 패턴 (개발/인프라에서 실제로 새는 곳)

| # | 경계면 | 흔한 버그 | QA 교차 비교 방법 |
|---|--------|-----------|-------------------|
| 1 | API 응답 ↔ 클라이언트/DTO | 필드명·타입·nullable 불일치 | 컨트롤러 응답 객체와 소비측 모델을 동시에 읽고 shape diff |
| 2 | OpenAPI 문서 ↔ 실제 구현 | 문서엔 있는데 구현 없음(또는 반대) | spec과 라우트 핸들러 교차 대조 |
| 3 | DB 마이그레이션 ↔ 엔티티 | 컬럼/제약/인덱스 누락·타입 불일치 | 마이그레이션 DDL과 엔티티 매핑 대조 |
| 4 | 앱 설정 ↔ k8s ConfigMap/Secret | 키 이름·필수값 누락 | application.yml 키와 ConfigMap/Secret 키 대조 |
| 5 | 서비스 포트 ↔ k8s Service/Ingress | 컨테이너 포트 ≠ Service targetPort | Deployment containerPort와 Service/Ingress 대조 |
| 6 | Terraform output ↔ 앱 환경변수 | output 이름 변경됐는데 앱이 옛 이름 참조 | tf output과 앱이 읽는 env 키 대조 |
| 7 | 알림 룰 ↔ 실제 메트릭 이름 | PrometheusRule이 존재하지 않는 메트릭 참조 | rule expr의 메트릭명과 앱 노출 메트릭 대조 |

> 1~3은 앱 내부 경계, 4~7은 앱↔인프라 경계. 혼합 레포는 4~7이 특히 잘 샌다
> (앱 팀과 인프라 팀의 컨텍스트가 분리돼 있어 서로의 변경을 모름). QA가 이 다리를 잇는다.

## QA 에이전트 정의 템플릿

```
---
name: qa
description: 통합 정합성 검증. 경계면(API↔클라이언트, 앱설정↔k8s, tf output↔앱env 등)을 교차 비교한다.
model: opus
subagent_type: general-purpose      # 검증 스크립트 실행 필요
scope: 전체 읽기 + _workspace/ 쓰기
---

## 핵심 역할
모듈 완성 직후마다 경계면을 교차 비교해 정합성 버그를 조기 발견한다.

## 작업 원칙
- 존재 확인이 아니라 shape 비교. 양쪽을 동시에 읽는다.
- 발견 즉시 보고(incremental). 전체 완성까지 미루지 않는다.
- 버그는 출처와 함께 기록: "Deployment containerPort=8080 ≠ Service targetPort=80".

## 입력/출력 프로토콜
- 입력: 완성된 모듈의 변경 파일 목록 (_workspace/{phase}_{agent}_*.md)
- 출력: _workspace/qa_findings.md (경계면별 정합/불일치 표)

## 에러 핸들링
- 한쪽만 존재(짝 없음)도 불일치로 보고. 추측으로 채우지 않는다.

## 팀 통신 프로토콜
- 수신: backend-dev / infra-dev의 "모듈 완성" 메시지
- 발신: 불일치 발견 시 해당 에이전트 + reviewer에게 SendMessage
```

## 통합 시점
- 파이프라인: 각 구현 단계 직후 QA 1회씩.
- 팬아웃/팬인: 취합 전 QA가 경계면 먼저 점검.
- 혼합 레포: 앱 변경과 인프라 변경이 만나는 지점(4~7)을 반드시 1회 이상.
