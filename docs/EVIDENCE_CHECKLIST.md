# Evidence you can genuinely show

Source files demonstrate what code exists. Successful run logs demonstrate execution. Neither alone proves historic work dates, production deployment or authorship. This package was newly prepared with AI assistance; review, run, modify and understand it before presenting it as your work. It is not a reconstruction of your existing Java app.

| Claim | Files | Evidence still needed |
|---|---|---|
| Java app runs locally | src/, scripts/test.sh, tests/ | Supplied local test log; rerun yourself |
| Docker image builds and starts | Dockerfile, compose.yaml | Successful build + container health output |
| Failed local release recovers | scripts/docker-demo.sh | Actual rollback log from your machine/CI |
| CI checks run | .github/workflows/ci.yml | Real Actions run URL and commit SHA |
| Image vulnerability scanning | CI Trivy stage | Actual scan JSON, including findings |
| Jenkins pipeline runs | Jenkinsfile | Jenkins build log; file alone is not a run |
| Terraform configuration exists | infra/ | Real init/validate output; cloud plan/apply separate |
| App deployed on AWS | docs/AWS_OPTIONAL.md | Actual EC2/SSM health output and resource evidence |
| SonarQube, ALB, ASG, blue-green, Slack alerts | NOT implemented here | Build and test separately or remove claims |
| Prometheus/Grafana stack | NOT implemented here | /metrics alone is not a monitoring stack |

## Evidence collection without AWS
```bash
mkdir -p reports
set -o pipefail
bash scripts/test.sh 2>&1 | tee reports/my-java-tests.txt
bash scripts/docker-demo.sh 2>&1 | tee reports/my-docker-recovery.txt
docker inspect --format '{{.State.Health.Status}}' darsh-devops-app
docker image inspect --format '{{.Id}}' java-devops-demo:good
```
Save terminal screenshots after running, not generated mock screenshots. Show commands, output and version/date. For failures, explain the cause and fix. Do not backdate commits or copy supplied test output as though you personally ran it.

## Suggested evidence filenames
`my-java-tests.txt`, `docker-health.png`, `rollback-test.txt`, `actions-run-url.txt`, `trivy.json`, `terraform-validate.txt`, `incident-001.md`.
Only create these when you have the corresponding actual output. Remove account IDs, credentials and private details before sharing. The included assistant validation is labelled separately.

## Resume wording as you progress
Now: "Java application ready; Docker packaging and AWS deployment in progress." Use your actual application status, not this starter as proof of past work.
After your local/CI run succeeds: "Built and tested a containerized Java service with GitHub Actions and health-check-based local rollback; AWS deployment in progress."
After an actual cloud deployment: add EC2/Terraform details and link sanitized cloud evidence. Don't invent improvement percentages or claim zero downtime: this lab restart has downtime.
