#!/usr/bin/env bash
set -euo pipefail

runner_source=/home/runner
registration_token_file=/run/secrets/github-runner-token

if [[ ! -f "$RUNNER_ROOT/.image-version" ]] ||
  [[ "$(<"$RUNNER_ROOT/.image-version")" != "$CARDMYSTIC_RUNNER_IMAGE_VERSION" ]]; then
  cp -a "$runner_source/." "$RUNNER_ROOT/"
  printf '%s\n' "$CARDMYSTIC_RUNNER_IMAGE_VERSION" >"$RUNNER_ROOT/.image-version"
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
    --url "$RUNNER_REPOSITORY_URL" \
    --token "$(<"$registration_token_file")" \
    --name "$RUNNER_NAME" \
    --labels "$RUNNER_LABELS" \
    --work "$RUNNER_WORK_DIRECTORY"
fi

exec ./run.sh
