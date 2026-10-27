# Upload and obtain a real repository link

Suggested name: `java-aws-devops-portfolio`.
Suggested description: `Java application, Docker packaging, CI security checks and optional AWS Terraform lab. AWS deployment in progress.`

1. Extract the ZIP. Open the inner `java-aws-devops-portfolio` folder.
2. On https://github.com/new select your account and create an EMPTY repository with the suggested name. Public makes recruiter access easier; review contents before publishing. Do not add a README, license or .gitignore there because these files already exist here.
3. Install Git and use Git Bash (Windows) or a terminal in the extracted inner folder.
4. Set your actual Git identity if needed, then run:
```bash
git init -b main
git add .
git status
# Check that .github/workflows/ci.yml is included and no credentials/state are staged.
git commit -m "Add Java DevOps application and reproducible lab"
git remote add origin https://github.com/YOUR_USERNAME/java-aws-devops-portfolio.git
git push -u origin main
```
Replace YOUR_USERNAME with your account. Authenticate via Git Credential Manager/browser, not a password embedded in the URL. Never paste a token into the README.

Alternative: use GitHub Desktop > Add existing repository (initialize with Git first) > Publish repository. Ensure the hidden `.github` folder is included. Upload extracted source files, not just the ZIP. A ZIP alone does not run Actions.

5. Open Actions and inspect the CI run. If Trivy finds high/critical vulnerabilities, keep the failed result, update the base image and rerun. Do not suppress results to manufacture a green build.
6. Download the real `app-evidence` artifact. Add selected sanitized evidence with the commit SHA and run URL. Terraform validation has a separate job log.
7. The real link is the browser address of the created repository. Based on your resume username it would be `https://github.com/DARSH-git-hub/java-aws-devops-portfolio` ONLY IF created under that account/name. It is not a verified existing repository.
8. Pin the repository to your GitHub profile and add its actual URL to the resume project title.

You may reference different folders of this repository for related project work, but describe it as one integrated portfolio rather than pretending the same implementation is two independent projects.
