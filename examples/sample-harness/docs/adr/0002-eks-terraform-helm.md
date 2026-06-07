# ADR-0002: AWS EKS(Terraform 프로비저닝) + Helm 배포

<!-- 산출물: docs/adr/0002-eks-terraform-helm.md. 결정 1개당 파일 1개. why + 트레이드오프를 남긴다. -->

- 상태: Accepted
- 날짜: 2026-06-07
- 관련: PRD §6(가용성·관측성) / architecture §2(컴포넌트 경계)

## 맥락 (Context)
orders-service는 무중단 롤링 배포, 다중 replica 가용성, Prometheus 기반 관측성이 필요한 백엔드다. 클라우드 인프라(클러스터·네트워크·IAM)는 코드로 재현·검토 가능해야 하고, 애플리케이션 배포는 환경별(dev/stg/prod) 값 주입과 버전 롤백이 쉬워야 한다. 위험 작업(클러스터 변경·배포)은 비가역적일 수 있어 계획과 적용을 분리해야 한다.

## 결정 (Decision)
컨테이너 오케스트레이션 플랫폼으로 AWS EKS를 채택하고, 클러스터·VPC·IAM 등 인프라는 Terraform으로 프로비저닝하며, 애플리케이션은 Helm 차트로 EKS에 배포한다.

## 근거 (Why)
- EKS: 관리형 Kubernetes로 컨트롤플레인 운영부담 절감, 롤링 배포·HPA·다중 replica·Prometheus 생태계 친화.
- Terraform: 선언적 IaC로 인프라를 코드 리뷰·`plan`으로 사전 검증, 환경별 디렉터리(`envs/{dev,stg,prod}`)로 분리.
- Helm: 차트+values로 환경별 설정(이미지 태그·replica·env·Secret 참조)을 템플릿화, 버전 릴리스/롤백 용이.
- 경계 분리: 인프라(Terraform)와 배포(Helm)를 나눠 변경 영향 범위를 좁히고 책임을 명확히 한다.

## 고려한 대안 (Alternatives)
| 대안 | 장점 | 단점 / 기각 이유 |
|------|------|------------------|
| ECS/Fargate | 운영 단순, AWS 통합 | k8s 생태계(Helm·Prometheus·HPA) 이탈, 이식성 저하 |
| 자체 관리 k8s(kubeadm/EC2) | 완전한 제어 | 컨트롤플레인 운영부담·보안 패치 비용 과다 |
| 생(raw) k8s 매니페스트(Helm 미사용) | 의존성 적음 | 환경별 값 중복·드리프트, 릴리스/롤백 추적 부재 |
| Terraform으로 앱까지 배포 | 단일 도구 | 앱 릴리스 주기와 인프라 변경 주기가 엉켜 blast radius 확대 |

## 트레이드오프 / 결과 (Consequences)
- 얻는 것: 재현 가능한 인프라, 환경별 배포 일관성, 무중단 배포·롤백, 관측성 통합
- 포기/감수: 두 도구(Terraform+Helm) 학습·운영 비용, EKS 비용
- 후속 영향: infra-dev는 `terraform validate`/`plan`·`helm template`/`--dry-run`까지만 수행하고 `terraform apply`/`helm upgrade`/`kubectl apply` 실행은 사람이 담당(루트 `claude.md` `# CRITICAL — Safety`). tf output↔app env, Helm values↔app config 정합성은 qa의 cross-boundary-check로 검증.
