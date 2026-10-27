# Java AWS DevOps Portfolio

A reproducible learning repository for a Java app, Docker packaging, CI checks and an optional AWS deployment lab. **AWS deployment is not completed or verified by this package.** No cloud resources are created by CI.

This newly generated starter includes a small demo Java service. It is not the source of Darsh's existing Java application and is not evidence of work completed in June–August 2026. Replace/adapt it, run it and explain your changes.

## Verified checks

[Passing CI run](https://github.com/DARSH-git-hub/java-aws-devops-portfolio/actions/runs/40570110934) — Java tests, Docker recovery, Trivy gate and Terraform validation.

## Start here — no AWS account
Requirements: full JDK 17, Python 3, Bash; Docker only for container tests. Windows: use WSL or Git Bash with JDK/Python installed.
```bash
bash scripts/test.sh
java -cp build/classes App
```
In another terminal:
```bash
curl http://localhost:8080/health
curl http://localhost:8080/
curl http://localhost:8080/metrics
```
Stop Java with Ctrl+C.

## Docker
```bash
docker compose up --build -d
curl --fail http://localhost:8080/health
docker compose logs
docker compose down
# Keep port 8080 free for the next dedicated-host demo:
bash scripts/docker-demo.sh
```
Cleanup the two lab containers when finished:
```bash
docker rm -f darsh-devops-app
# Only if it exists:
docker rm -f darsh-devops-previous
```
Review the script before running on a host with other containers.

## What is included
- Java HTTP service and eight integration tests, including an unhealthy release.
- Multi-stage Dockerfile with a non-root runtime and health check; Compose for local use.
- Bash deployment script with health checks and restoration of the prior container.
- GitHub Actions: Java tests, Docker recovery test, Trivy gate and Terraform validation.
- Alternate Jenkinsfile requiring your own dedicated Linux agent.
- Optional AWS Terraform lab: VPC, EC2, restricted ingress, SSM role, private S3.
- Evidence instructions, actual assistant test results, upload guide and troubleshooting.

## Read before adding resume claims
See [evidence status](evidence/STATUS.md) and [evidence checklist](docs/EVIDENCE_CHECKLIST.md). GitHub Actions has now verified Java tests, Docker deployment/recovery, the Trivy gate and Terraform init/validate. Jenkins and AWS deployment remain unverified. Having their configuration files is not proof they ran. No fabricated screenshots, cloud logs, certification or historic metrics are included.

## Guides
- [Upload to GitHub and obtain the actual URL](docs/UPLOAD_TO_GITHUB.md)
- [Optional AWS deployment and cleanup](docs/AWS_OPTIONAL.md)
- [Architecture and troubleshooting](docs/ARCHITECTURE.md)
- [Evidence checklist and resume wording](docs/EVIDENCE_CHECKLIST.md)

## Official references
- https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-new-repository
- https://docs.github.com/en/repositories/working-with-files/managing-files/adding-a-file-to-a-repository
- https://github.com/actions/setup-java
- https://github.com/aquasecurity/trivy-action
- https://developer.hashicorp.com/terraform/tutorials/aws-get-started
- https://docs.docker.com/get-started/

Action major versions and container tags can move. For a hardened project, review upstream releases and pin verified immutable SHAs/image digests. This lab has no production availability/security guarantee.
