#!/usr/bin/env bash
# Boots the image and asserts GET /ping on the public port answers "pong". /ping makes no call to
# the Central API or Keycloak, so placeholder settings are enough. That proves the released binaries
# start on this runtime and bind their config — the things a runtime bump can break.
#
#   scripts/smoke-test.sh <image>
set -euo pipefail

IMAGE=${1:?usage: smoke-test.sh <image>}
NAME=bridge-smoke-$$
PORT=${SMOKE_PORT:-18090}

cleanup() { docker rm -f "$NAME" >/dev/null 2>&1 || true; }
trap cleanup EXIT

docker run -d --name "$NAME" -p "127.0.0.1:$PORT:8080" \
  -e Backend__BaseUrl=http://backend.invalid:8080 \
  -e Keycloak__BaseUrl=http://keycloak.invalid/ \
  -e Keycloak__Realm=smoke \
  -e Keycloak__ClientId=smoke \
  -e Keycloak__ClientSecret=smoke \
  "$IMAGE" >/dev/null

for _ in $(seq 1 30); do
  curl -fs "http://127.0.0.1:$PORT/ping" >/dev/null 2>&1 && break
  [ "$(docker inspect -f '{{.State.Running}}' "$NAME")" = true ] || break
  sleep 1
done
if ! curl -fs "http://127.0.0.1:$PORT/ping" | grep -q pong; then
  docker logs "$NAME" 2>&1 | tail -50
  echo "FAIL: bridge did not answer /ping" >&2
  exit 1
fi
echo "ok: bridge $(docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' "$IMAGE" | sed -n 's/^ELIFERPG_BRIDGE_VERSION=//p') answers /ping on $(docker exec "$NAME" dotnet --list-runtimes | grep AspNetCore)"
