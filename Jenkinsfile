pipeline {
  agent any
  options { timestamps(); timeout(time: 15, unit: 'MINUTES'); disableConcurrentBuilds() }
  stages {
    stage('Test Java') { steps { sh 'bash scripts/test.sh' } }
    stage('Container and rollback lab') { steps { sh 'bash scripts/docker-demo.sh' } }
    stage('Image security gate') {
      steps { sh 'mkdir -p reports; trivy image --severity HIGH,CRITICAL --exit-code 1 --format json --output reports/trivy.json java-devops-demo:good' }
    }
    stage('Terraform validation only') {
      steps { sh 'terraform -chdir=infra init -backend=false; terraform -chdir=infra validate' }
    }
  }
  post { always { archiveArtifacts artifacts: 'reports/**', allowEmptyArchive: true } }
}
// Dedicated Linux agent prerequisites: JDK17, Python3, Docker access, curl, Trivy, Terraform.
// Do not run this on a shared production Docker host. No cloud apply is included.
