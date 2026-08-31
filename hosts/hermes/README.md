# Hermes

## GitHub Actions runner

Hermes hosts an Ubuntu-based, repository-scoped runner container for
`CardMystic/cardmystic-platform`. Before its first start, use an administrator's
authenticated GitHub CLI to create a one-time repository registration token and
store it on Hermes:

```console
sudo install -d -m 0700 /var/lib/github-runner-token
gh api --method POST \
  repos/CardMystic/cardmystic-platform/actions/runners/registration-token \
  --jq .token | tr -d '\n' | sudo tee \
  /var/lib/github-runner-token/cardmystic-platform >/dev/null
sudo chmod 0600 /var/lib/github-runner-token/cardmystic-platform
```

Create the token file before activating the NixOS configuration. After
deployment, verify the runner with:

```console
systemctl status github-runner-cardmystic-platform
```

The registration token expires after one hour, but the registered runner keeps
working across container and host restarts because its state is stored under
`/var/lib/github-actions-runner`. Generate a fresh token before deleting that
state or changing its URL, name, labels, or other registration settings.

Jobs can target Hermes with:

```yaml
runs-on: [self-hosted, linux, x64, hermes]
```

Only workflows from the private repository should use this runner because job
steps can control Hermes's Docker daemon through the mounted Docker socket.
