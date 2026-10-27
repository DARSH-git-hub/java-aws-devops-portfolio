#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker build -t java-devops-demo:good .
bash scripts/deploy-local.sh java-devops-demo:good
printf 'FROM java-devops-demo:good\nENV FAIL_HEALTH=true\n' | docker build -t java-devops-demo:bad -
if bash scripts/deploy-local.sh java-devops-demo:bad; then
  echo 'ERROR: unhealthy image unexpectedly accepted'; exit 1
fi
for ((i=0;i<20;i++)); do
  if curl --fail --silent http://127.0.0.1:8080/health; then
    echo; echo 'PASS: bad deployment rejected and original app recovered.'; exit 0
  fi
  sleep 1
done
exit 1
