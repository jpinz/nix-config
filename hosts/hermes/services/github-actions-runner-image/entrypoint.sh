#!/usr/bin/env bash
set -euo pipefail

: "${RUNNER_NAME:?}"
: "${RUNNER_ORG:?}"
: "${RUNNER_LABELS:?}"

token_file=/run/secrets/github-runner-pat
if [[ ! -f "$token_file" || ! -r "$token_file" || ! -s "$token_file" ]]; then
  echo "A readable, nonempty PAT file is required at $token_file." >&2
  exit 1
fi

daemon_pid=
runner_pid=
runner_id=

github_api() {
  local token
  token="$(<"$token_file")"
  if [[ -z "${token//[[:space:]]/}" ]]; then
    echo "The runner PAT file is blank; provision a GitHub PAT before starting the pool." >&2
    return 1
  fi
  GH_TOKEN="$token" gh api "$@"
}

cleanup() {
  trap - EXIT INT TERM
  if [[ -n "$runner_pid" ]]; then
    kill -TERM "$runner_pid" 2>/dev/null || true
    wait "$runner_pid" 2>/dev/null || true
  fi
  if [[ -n "$runner_id" ]]; then
    github_api --method DELETE "orgs/$RUNNER_ORG/actions/runners/$runner_id" >/dev/null 2>&1 || true
  fi
  if [[ -n "$daemon_pid" ]]; then
    kill -TERM "$daemon_pid" 2>/dev/null || true
    wait "$daemon_pid" 2>/dev/null || true
  fi
}
trap cleanup EXIT
trap 'exit 143' TERM
trap 'exit 130' INT

install -d -o runner -g runner /runner-cache \
  /runner-cache/toolcache /runner-cache/dotnet /runner-cache/playwright \
  /runner-cache/nuget /runner-cache/xdg /runner-cache/npm /runner-cache/share
cp -a --no-clobber /opt/playwright/. /runner-cache/playwright/
chown -R runner:runner /runner-cache/playwright
install -d -o runner -g runner /home/runner/.nuget /home/runner/.local
ln -s /runner-cache/nuget /home/runner/.nuget/packages
ln -s /runner-cache/xdg /home/runner/.cache
ln -s /runner-cache/npm /home/runner/.npm
ln -s /runner-cache/share /home/runner/.local/share

dind dockerd --host=unix:///var/run/docker.sock --group=docker --storage-driver=overlay2 \
  --bip=172.30.0.1/24 --default-address-pool=base=172.31.0.0/16,size=24 &
daemon_pid=$!
for attempt in {1..60}; do
  if docker info >/dev/null 2>&1; then
    break
  fi
  kill -0 "$daemon_pid"
  if [[ "$attempt" == 60 ]]; then
    echo "The isolated Docker daemon did not become ready." >&2
    exit 1
  fi
  sleep 1
done

docker ps --all --quiet | xargs --no-run-if-empty docker rm --force
docker network prune --force
docker volume prune --force --all

registration_token="$(github_api --method POST "orgs/$RUNNER_ORG/actions/runners/registration-token" --jq .token)"
cd /home/runner
runuser -u runner -- ./config.sh \
  --unattended \
  --replace \
  --ephemeral \
  --disableupdate \
  --url "https://github.com/$RUNNER_ORG" \
  --token "$registration_token" \
  --name "$RUNNER_NAME" \
  --labels "$RUNNER_LABELS" \
  --work _work
unset registration_token
runner_id="$(jq -r .agentId .runner)"

runuser -u runner -- ./run.sh &
runner_pid=$!
wait -n "$runner_pid" "$daemon_pid"