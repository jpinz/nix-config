#!/usr/bin/env bash
set -euo pipefail

runner_source=/home/runner
registration_token_file=/run/secrets/github-runner-token

if [[ ! -x "$RUNNER_ROOT/run.sh" ]]; then
  cp -a "$runner_source/." "$RUNNER_ROOT/"
fi

cd "$RUNNER_ROOT"

if [[ ! -f .runner ]]; then
  if [[ ! -s "$registration_token_file" ]]; then
    echo "A GitHub runner registration token is required for initial setup." >&2
    exit 1
  fi

  ./config.sh \
    --unattended \
    --replace \
    --url "$RUNNER_URL" \
    --token "$(<"$registration_token_file")" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "$RUNNER_WORK_DIRECTORY"
fi

exec ./run.sh
