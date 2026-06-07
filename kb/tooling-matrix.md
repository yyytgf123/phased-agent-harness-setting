# Tooling Matrix — 도구 → 검증 명령

스택을 읽고 스킬/CLAUDE.md의 명령을 아래로 치환한다.

## 앱
| 도구 | build | test | lint/format |
|------|-------|------|-------------|
| Gradle | `./gradlew build` | `./gradlew test` | `./gradlew spotlessCheck` / `checkstyleMain` |
| Maven | `mvn package` | `mvn test` | `mvn checkstyle:check` |
| npm/Node | `npm run build` | `npm test` | `npm run lint` (eslint) |
| pnpm | `pnpm build` | `pnpm test` | `pnpm lint` |
| uv/Python | `uv build` | `pytest` | `ruff check .` |
| Poetry | `poetry build` | `pytest` | `ruff check .` |

## 마이그레이션 (작성까지만, 실행은 사람 승인)
| 도구 | 검증 | 금지(사람 승인) |
|------|------|------------------|
| Flyway | `flyway validate` / info | `flyway migrate` |
| Liquibase | `liquibase validate` | `liquibase update` |
| Alembic | `alembic check` | `alembic upgrade head` |

## 인프라 (plan/검증까지만)
| 도구 | validate/lint | plan/diff | 금지(사람 승인) |
|------|---------------|-----------|------------------|
| Terraform | `terraform validate` / `tflint` | `terraform plan` | `terraform apply` / `destroy` |
| Pulumi | `pulumi preview` | `pulumi preview --diff` | `pulumi up` |
| Helm | `helm lint` | `helm template` / `helm diff upgrade` | `helm upgrade --install` |
| Kustomize | — | `kubectl kustomize` | — |
| k8s | `kubeval` / `kubeconform` | `kubectl apply --dry-run=client` | `kubectl apply` / `delete` |

## 모니터링
| 도구 | 검증 |
|------|------|
| Prometheus | `promtool check rules` / `promtool check config` |
| Grafana | 대시보드 JSON 스키마 검증 (provisioning 시 lint) |
| Loki | `logcli` 쿼리 검증 (읽기) |

## CI/CD (읽기·검증 위주)
| 도구 | 검증 |
|------|------|
| GitHub Actions | `actionlint` |
| GitLab CI | `gitlab-ci-lint` (API) |
| ArgoCD | `argocd app diff` (apply는 사람) |

> 표에 없는 도구는 version-policy의 검색 규칙으로 표준 명령을 확인한 뒤 채운다.
