# Hermes

## GitHub Actions runners

Hermes runs a pool of Ubuntu runners for the `CardMystic` organization,
configured in [services/github-actions-runner.nix](services/github-actions-runner.nix).
This follows the count-based organization described in the
[srvos runner guide](https://deepwiki.com/nix-community/srvos/5.1-github-actions-runner),
using NixOS's `virtualisation.oci-containers` module for container lifecycle.
Current srvos removed its runner role due to lack of maintenance. Ubuntu keeps
the existing CI workflow's setup actions and Playwright `--with-deps` working
without application-repository changes.

Each slot runs its own Docker daemon inside its own network namespace. The
workflow's Redis service can bind `127.0.0.1:6399` in every slot concurrently;
neither that port nor the nested Docker API is published on Hermes. There is no
host Docker socket mount and no host networking.

### Authentication

Create a fine-grained PAT with `CardMystic` as the resource owner and organization
permission **Self-hosted runners: Read and write**. Complete any required
organization approval. A classic PAT with `admin:org` also works.

Provision the PAT directly on Hermes, outside this repository and the Nix store.
The source file below must contain only the token, without a trailing newline:

```console
sudo install -d -m 0700 /var/lib/github-runner-token
sudo install -o root -g root -m 0600 /secure/path/cardmystic-pat \
  /var/lib/github-runner-token/cardmystic-pat
```

Do this before activating the configuration. The old one-hour registration
token is not suitable: each ephemeral runner registers again after every job.
The separate `cardmystic-pat` filename avoids accidentally reusing that token.
Rotate the PAT before expiry by replacing the file and restarting idle runners.

### Scaling and lifecycle

`services.cardmystic-runners.count` defaults to `2`, allowing two concurrent jobs.
Set it in the Hermes host configuration and rebuild to resize the pool. This is
fixed capacity, not queue-driven autoscaling. Every slot gets a separate runner
registration, workspace, Docker daemon, network namespace, cache, and unit:

- GitHub names: `hermes-cardmystic-1`, `hermes-cardmystic-2`.
- Units: `github-runner-cardmystic-1`, `github-runner-cardmystic-2`.
- Outer containers: `cardmystic-1`, `cardmystic-2`.
- Persistent data: `/var/lib/github-actions-runner-pool/cardmystic-<n>`.

Names keep their numeric suffix even at `count = 1`. Hostnames prefix GitHub
registration names, so the same configuration can also be used on other hosts.
The inner daemon uses `172.30.0.0/24` for its default bridge and allocates job
networks from `172.31.0.0/16`, avoiding Docker's usual outer `172.17.0.0/16`.
Reserve these inner ranges; change them in the entrypoint if they overlap a
network your jobs need to reach.

After one job the ephemeral runner exits and systemd recreates its container.
The checkout, home directory, registration credentials, and OS changes are
discarded. Startup removes leftover containers, networks, and unused volumes
from that slot's private daemon, preserving images and daemon build cache.
It never prunes the host daemon or another slot. Graceful shutdown attempts to
remove the GitHub registration; remove stale registrations after forced stops.

Pause submissions and wait for active jobs before deployment or resizing;
stopping a service can interrupt its job. Increasing the count increases CPU,
RAM, and disk contention with the Minecraft service. Measure concurrent jobs
before raising the count further. Removed slots' data is retained for manual
cleanup.

### Workflow environment

The existing label selector remains valid:

```yaml
runs-on: [self-hosted, linux, x64, hermes]
```

The [image](services/github-actions-runner-image/Dockerfile) includes Node
24.13.0/npm, Python 3, GCC/Make, Git/GitHub CLI, Docker/Buildx, and Chromium with
Playwright 1.61.1's Ubuntu dependencies. The workflow still controls its exact
.NET, Node, pnpm, Python, uv, and Playwright versions through its setup actions
and lockfiles. Newer browser revisions can be downloaded normally. Azure CLI
and Bicep are not included: the linked CI job mocks Azure calls and validates
generated Bicep as text. Deployment jobs needing those tools need another image
or explicit installation.

Each slot retains the following under its `cache` directory:

- `toolcache`: setup-node/setup-python tool installations.
- `dotnet`: SDKs installed by setup-dotnet.
- `nuget`: linked to `~/.nuget/packages`, matching the workflow's cache action.
- `xdg`, `npm`, `share`: download caches and pnpm's default data/store location.
- `playwright`: seeded from the image, writable for future browser versions.

Cold slots still download their SDKs and dependencies. Remote cache actions
remain unchanged and still incur their own restore/save costs. The workflow's
Buildx cleanup can remove builder-specific cache volumes; image reuse is not a
guarantee that every build layer survives. Caches grow over time: monitor disk
usage and clear an idle slot's cache or Docker data only while its unit is stopped.

The reference job took 13m51s: web verification used 4m05s and distributed-stack
verification 6m50s. These dominate runtime; cache warming reduces repeated
downloads but is not a measured speedup of those tests. Two slots improve
throughput across jobs, not parallelism within one job. The workflow cancels
older runs on the same ref, so concurrent validation needs different refs.

**Security:** nested Docker requires privileged outer containers. This is
operational isolation, not a hostile-code security boundary. Jobs have sudo in
their own container, can access its mounted PAT, and may compromise the host.
Use a least-privilege PAT, restrict the runner group to trusted private
repositories, and do not execute untrusted pull-request code. Persistent caches
also carry state between jobs. Use separate VMs for mutually untrusted workloads.

### Migration and verification

1. Provision the PAT and review the security notes above.
2. Pause submissions, let the old `hermes` runner finish its job, then stop the
    old container unit with `sudo systemctl stop github-runner-cardmystic`.
3. Activate from the repository root with `sudo nixos-rebuild switch --flake .#hermes`.
4. Verify the services and both registrations in the organization's Actions
    settings:

    ```console
    systemctl status github-actions-runner-image github-runner-cardmystic-1 github-runner-cardmystic-2
    journalctl -u 'github-runner-cardmystic-*' -n 100 --no-pager
    ```

5. Run two representative jobs concurrently from different refs. Confirm both
  Redis services start, both jobs finish, and the
  runners return online with fresh checkouts and warm caches for subsequent jobs.
6. Remove the old `hermes` registration in GitHub. Once migration is confirmed,
  the old `/var/lib/github-actions-runner/cardmystic` state, registration-token
  file, and `localhost/cardmystic-actions-runner` image can be removed manually.
  The configuration deliberately does not delete these rollback artifacts.

The shared image builds once before the runner services start. Its tag is
derived from the image context; source changes trigger a new image and runner
restart. The base runner image and Node download are pinned in the Dockerfile,
and must be updated there when upgrading. Ubuntu packages are resolved at image
build time. Runner self-updates are disabled to keep the image authoritative.

To check port isolation before allowing workflows, run this while both slots
are idle and submissions are paused:

```console
for slot in cardmystic-1 cardmystic-2; do
  sudo docker exec "$slot" docker run --detach --rm --name runner-port-smoke \
    --publish 127.0.0.1:6399:6379 redis:8.6
done
for slot in cardmystic-1 cardmystic-2; do
  sudo docker exec "$slot" docker exec runner-port-smoke redis-cli ping
  sudo docker exec "$slot" docker rm --force runner-port-smoke
done
```

Both daemons must accept the same port and return `PONG`. Always remove the
smoke containers before resuming submissions, including after a partial failure.
