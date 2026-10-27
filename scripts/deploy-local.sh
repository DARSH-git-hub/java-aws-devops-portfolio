#!/usr/bin/env bash
# For a dedicated lab Docker host, not production. Brief downtime is expected.
set -euo pipefail
image=${1:?Usage: bash scripts/deploy-local.sh IMAGE}
[[ "$image" =~ ^[a-zA-Z0-9][a-zA-Z0-9._/:@-]+$ ]] || exit 2
name=darsh-devops-app
previous=darsh-devops-previous
for c in "$name" "$previous"; do
  if docker inspect "$c" >/dev/null 2>&1; then
    [[ "$(docker inspect -f '{{index .Config.Labels "portfolio.owner"}}' "$c")" == 'darsh-devops-lab' ]] || { echo "Refusing to alter unrelated container $c"; exit 2; }
  fi
done
docker image inspect "$image" >/dev/null
if docker inspect "$previous" >/dev/null 2>&1; then docker rm -f "$previous"; fi
had_previous=false
if docker inspect "$name" >/dev/null 2>&1; then
  docker stop "$name"; docker rename "$name" "$previous"; had_previous=true
fi
recover() {
  docker logs "$name" 2>&1 || true
  docker rm -f "$name" >/dev/null 2>&1 || true
  if "$had_previous"; then docker rename "$previous" "$name"; docker start "$name"; fi
  echo 'Deployment failed; previous container restored when available.'
}
if ! docker run -d --name "$name" --label portfolio.owner=darsh-devops-lab \
  -p 127.0.0.1:8080:8080 --read-only --tmpfs /tmp --cap-drop ALL \
  --security-opt no-new-privileges:true "$image"; then recover; exit 1; fi
for ((i=0;i<30;i++)); do
  status=$(docker inspect -f '{{.State.Health.Status}}' "$name" 2>/dev/null || true)
  if [[ "$status" == healthy ]]; then echo 'Deployment healthy; prior container retained for rollback.'; exit 0; fi
  sleep 2
done
recover
exit 1
