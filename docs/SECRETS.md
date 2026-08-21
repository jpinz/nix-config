# Secret Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) with age
recipients. Encrypted files are committed to Git; decrypted values exist only in
runtime files under `/run/secrets`.

## Identities

`secrets/calculon.yaml` is encrypted to two independent recipients:

- Julian's editor identity at `~/.config/sops/age/keys.txt`
- Calculon's SSH host identity at `/etc/ssh/ssh_host_ed25519_key`

The private editor identity is not reproducible from this repository. Store a
backup in a password manager or other encrypted backup, including its file name
and required mode (`0600`). Never commit it.

## Edit Secrets

Open the encrypted document from the repository root:

```bash
nix develop -c sops secrets/calculon.yaml
```

SOPS decrypts into a temporary editor buffer and encrypts the result when the
editor exits. Keep service credentials as scalar values under their existing
uppercase keys.

Validate the Calculon configuration without activating it:

```bash
nix eval path:$PWD#nixosConfigurations.calculon.config.system.build.toplevel.drvPath
```

Changes to managed credentials automatically restart their consuming services.

## New Workstation

1. Restore `~/.config/sops/age/keys.txt` from the encrypted backup.
2. Set the directory mode to `0700` and the file mode to `0600`.
3. Clone this repository and enter `nix develop`.
4. Confirm access with `sops decrypt secrets/calculon.yaml >/dev/null`.

The checked-in ciphertext is portable; the private editor identity is the
recovery key that makes it useful on a new workstation.

## Replace A Host

Generate the replacement host's SSH keys before retiring the old host. Convert
its Ed25519 public host key to an age recipient:

```bash
ssh-keyscan -p 2222 calculon.home \
  | nix shell nixpkgs#ssh-to-age -c ssh-to-age
```

Replace Calculon's public recipient in `.sops.yaml`, then re-encrypt the data key
for the new recipients:

```bash
nix develop -c sops updatekeys secrets/calculon.yaml
```

The backed-up editor identity can perform this operation even if the old host is
gone.

## Calculon Migration

SOPS currently manages Glance API keys, Copyparty account passwords, and the
Doplarr Discord token. Sonarr and Radarr keys are shared by Glance and Doplarr
from one encrypted value each.

After the first successful deployment, verify `glance`, `copyparty`, and
`doplarr`, then remove their obsolete files:

```bash
sudo rm /etc/copyparty/julian-password /etc/copyparty/david-password
sudo rm /etc/doplarr/doplarr.env
```

Rotate the six API keys previously embedded in the Glance Nix module; removing
them from the current source does not remove them from Git history or old Nix
store paths. Rotate both Copyparty passwords as well because their old files were
world-readable.

Cloudflare remains a root-only manual token. Notifiarr has no local token to
import, and SABnzbd remains in legacy writable-config mode. These can be migrated
separately once their source credentials and service configuration are ready.