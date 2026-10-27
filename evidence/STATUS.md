# Verification status

This package was prepared on 27 October 2026. No past project dates are inferred.

| Check | Result |
|---|---|
| Java compilation on OpenJDK 17 | PASS |
| Java HTTP integration tests | PASS: 8 tests |
| Bash syntax checks | PASS: build, test, deploy, Docker demo and bootstrap scripts |
| YAML parsing | PASS: Compose and GitHub Actions syntax parsed locally |
| Docker build/runtime/rollback | PASS in GitHub Actions |
| GitHub Actions | PASS: run 40570110934 |
| Jenkins | NOT RUN |
| Trivy security scan | PASS: configured HIGH/CRITICAL image gate |
| Terraform init/validate | PASS in GitHub Actions |
| Terraform plan/apply | NOT RUN; no cloud provisioning |
| AWS deployment | NOT RUN; no AWS resources created |

Java tests verify health, version, unknown path, exact route handling, method rejection, increasing metric counter, unhealthy release status and invalid-port failure. YAML parsing and Bash syntax checks do not prove runtime success.

See assistant-java-tests.txt for real output. No screenshots or cloud results were fabricated. Re-run the commands yourself and add your actual logs/Actions URL. Current source hashes are in SHA256SUMS.txt.

## Verified CI run

https://github.com/DARSH-git-hub/java-aws-devops-portfolio/actions/runs/40570110934

Tested commit: `b4af2d68396df8fd1a7690b30b2cf8a4de862a6b`. Both jobs succeeded. See the GitHub log excerpts in this folder. The initial run found a Terraform syntax error, fixed in the tested commit.
