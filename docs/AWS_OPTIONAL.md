# Optional AWS deployment — NOT executed in the supplied evidence

No AWS account is needed for Java, Docker or CI testing. Terraform validation installs a provider but does not create resources. A real plan requires AWS access; apply can incur charges. Confirm account eligibility and prices first; this is not a free-tier guarantee.

## Resources and access
VPC, subnet, internet route, EC2 with encrypted disk, SSM instance role, and private S3 artifact bucket. No inbound SSH/HTTP ports. Public IPv4 provides outbound connectivity to package repositories and SSM and may cost money. No ALB, NAT gateway, ASG or CloudWatch log stack is provided. No claim of those deployments is supported by this repository.

## Validation, before any AWS spending
```bash
terraform -chdir=infra init -backend=false
terraform -chdir=infra fmt
terraform -chdir=infra validate
```
Commit the generated `.terraform.lock.hcl`; never commit state or credentials.

## Optional paid lab, only when you decide to proceed
Authenticate using your own AWS profile/SSO outside this repository. Do not put keys in files.
```bash
terraform -chdir=infra plan -out=lab.tfplan
# Read the plan and account costs before explicitly applying:
terraform -chdir=infra apply lab.tfplan
terraform -chdir=infra output
```
The instance role reads S3 objects only from the lab bucket. Your operator identity separately needs permissions to provision the listed infrastructure, upload lab artifacts and start SSM sessions. IAM creation may be restricted by your account administrator.

## Transfer the tested image without a public Docker registry
On your laptop, replace BUCKET with the Terraform output:
```bash
docker build -t java-devops-demo:release-1 .
docker save java-devops-demo:release-1 -o /tmp/java-app.tar
aws s3 cp /tmp/java-app.tar s3://BUCKET/java-app.tar
```
Open EC2 > instance > Connect > Session Manager (wait for SSM and bootstrap). On the instance:
```bash
aws s3 cp s3://BUCKET/java-app.tar /tmp/java-app.tar
sudo docker load -i /tmp/java-app.tar
sudo docker run -d --name java-app --restart unless-stopped \
  -p 127.0.0.1:8080:8080 --read-only --tmpfs /tmp \
  --cap-drop ALL --security-opt no-new-privileges:true java-devops-demo:release-1
curl --fail http://127.0.0.1:8080/health
sudo docker logs java-app
```
If Docker is missing, examine `/var/log/cloud-init-output.log`. The demo is deliberately not internet-facing. For local browser access install AWS Session Manager plugin on your laptop, then:
```bash
aws ssm start-session --target INSTANCE_ID \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["8080"],"localPortNumber":["8081"]}'
```
Open http://localhost:8081. Deployment is manual; CI does not deploy to AWS. For remote rollback, use the separately tested lab script on that dedicated instance after copying it there, rather than claiming automated cloud rollback from a local test.

## Clean up
Remove only the lab artifact, then review and confirm destroy:
```bash
aws s3 rm s3://BUCKET/java-app.tar
terraform -chdir=infra destroy
```
Confirm EC2, attached volume, bucket and public address are gone. Stop alone can leave chargeable resources. Preserve sanitized screenshots/logs before cleanup; no ongoing live endpoint is required on your resume.
