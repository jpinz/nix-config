# Calculon

Calculon is an [Intel NUC7i5BNH][hardware] running NixOS. It is the home media
server, download automation host, file server, and home-services host. The Intel
i5-7260U GPU is configured for Quick Sync hardware transcoding.

## Architecture

- Hostname: `calculon` (`calculon.home` on the LAN)
- Remote administration: SSH on port `2222`, public-key authentication only
- Private remote access: Tailscale
- Public access: selected routes through a Cloudflare Tunnel; ingress rules are
  managed in Cloudflare, not in this repository
- Local reverse proxy: Caddy on port `80`, restricted to private LAN and
  Tailscale address ranges
- Service account model: media services share the `services` group so they can
  move files between the download and library directories

### Storage

The Disko configuration assumes this exact device layout:

<!-- markdownlint-disable MD013 -->

| Devices | Pool | Layout | Mount point | Purpose |
| --- | --- | --- | --- | --- |
| `/dev/sda` | `zroot` | Single-disk ZFS | `/`, `/nix`, `/home` | Operating system and service state |
| `/dev/sdb` through `/dev/sde` | `tank` | Four-disk RAID-Z | `/mnt/data` | Media library |

<!-- markdownlint-enable MD013 -->

Both pools use Zstandard compression with access-time updates disabled. The
configuration creates these shared directories with group-writable, setgid
permissions:

```text
/mnt/downloads/{complete,incomplete}
/mnt/data/{tv,anime,movies,music,ebooks}
```

`/mnt/downloads` is on the system pool; only `/mnt/data` is on `tank`. RAID-Z is
not a backup, and this configuration does not currently configure ZFS snapshots,
replication, or an off-site backup.

## Services

Unless noted otherwise, web services are accessed over private networking at
`http://calculon.home`. Services behind Caddy are bound to loopback and should
be opened using their path rather than their application port.

<!-- markdownlint-disable MD013 -->

| Service | Address | Purpose |
| --- | --- | --- |
| Glance | `/dashboard` | Home dashboard and service status |
| Sonarr | `/sonarr` | TV and anime library automation |
| Radarr | `/radarr` | Movie library automation |
| Lidarr | `/lidarr` | Music library automation |
| Prowlarr | `/prowlarr` | Indexer management for the Arr applications |
| SABnzbd | `/sabnzbd` | Usenet downloader |
| Bazarr | `:6767` | Subtitle management |
| Profilarr | `:6868` | Arr quality profiles and custom formats |
| Doplarr | Discord only | Discord requests routed to Sonarr and Radarr |
| Plex | `:32400/web` | Media streaming and transcoding |
| Tautulli | `:8181` | Plex monitoring and history |
| Navidrome | `/navidrome` | Music streaming from `/mnt/data/music` |
| FreshRSS | `/freshrss` | RSS feed aggregation and reading |
| Audiobookshelf | `/audiobookshelf` or `:8888` | Audiobook streaming |
| Shelfmark | `/shelfmark` or `:8084` | Ebook acquisition into `/mnt/data/ebooks` |
| Copyparty | `/copyparty` | Authenticated web access to `/mnt/data` |
| Samba | `\\calculon\data`, `\\calculon\downloads` | LAN file shares for `julian` |
| Homebox | `:7745` | Home inventory |
| Notifiarr | `/notifiarr` | Media-stack monitoring and Discord integration |
| RustDesk Server | RustDesk protocol ports | Private remote-desktop rendezvous and relay |

<!-- markdownlint-enable MD013 -->

Calibre-Web and the Grafana/OpenTelemetry stack have configuration files in the
repository but are not currently imported and therefore are not enabled.

## Required Secrets

Glance, Copyparty, Doplarr, and FreshRSS credentials are encrypted in
`secrets/calculon.yaml` and deployed by sops-nix. Follow the repository's
[secret management guide](../../docs/SECRETS.md) to edit or recover them.

The remaining credentials below are created directly on Calculon and must not
be committed to this repository.

### Cloudflare Tunnel

Obtain the tunnel token from the Cloudflare Zero Trust dashboard:

```bash
sudo install -d -m 0755 /etc/cloudflared
sudo install -m 0600 /dev/null /etc/cloudflared/tunnel-token
sudoedit /etc/cloudflared/tunnel-token
sudo systemctl restart cloudflared-tunnel
```

The file contains only the tunnel token, with no variable name.

### SABnzbd

SABnzbd is currently in the NixOS module's legacy writable-config mode because
this host retains `system.stateVersion = "23.05"`. Configure these credentials
through `http://calculon.home/sabnzbd`; they persist in
`/var/lib/sabnzbd/sabnzbd.ini`:

- Newshosting username and password
- Tweaknews username and password
- Optional SABnzbd web username and password
- Generated API and NZB keys used by other applications

Although `services/sabnzbd.nix` declares
`/var/lib/sabnzbd/secrets.ini`, NixOS does not merge that file while the legacy
`services.sabnzbd.configFile` default is active. Do not rely on it during a new
installation. To migrate to the declared settings and separate secret INI,
first explicitly set `services.sabnzbd.configFile = null`, rebuild, and verify
the generated configuration before removing the credentials from
`sabnzbd.ini`.

### Doplarr

Set up Sonarr and Radarr first. Their API keys and the Discord bot token are
managed through SOPS and rendered to Doplarr's runtime environment file.

Doplarr expects the `1080p Balanced` quality profile in both Arr applications
and the `/mnt/data/tv` and `/mnt/data/anime` root folders in Sonarr.

### Notifiarr

Link the Notifiarr account to Discord at <https://notifiarr.com>, add the
server, and copy the API key from the profile page:

```bash
sudo install -d -m 0750 -o root -g root /etc/notifiarr
sudo install -m 0600 -o root -g root /dev/null /etc/notifiarr/notifiarr.env
sudoedit /etc/notifiarr/notifiarr.env
```

```dotenv
DN_API_KEY=REPLACE_ME
```

```bash
sudo systemctl restart podman-notifiarr
```

Optional per-application checks can be added to
`/etc/notifiarr/notifiarr.conf`. That file and Notifiarr's generated client
state persist under `/etc/notifiarr`.

### Glance Credentials

Glance reads its Sonarr, Radarr, Prowlarr, SABnzbd, UniFi, and Immich API keys
from a SOPS-rendered runtime environment file. Rotate all six keys because their
previous values remain in Git history and old Nix store paths. UniFi and Immich
are external dependencies; they are not hosted by Calculon.

## First-Run Setup

Complete these steps in order after the first successful system deployment.

### 1. Verify Administrative Access

Verify SSH before closing the local console:

```bash
ssh -p 2222 julian@calculon.home
```

Authenticate the host to the tailnet and verify its assigned address:

```bash
sudo tailscale up
tailscale status
```

### 2. Create Local Credentials

Create the remaining manual secret files documented above. A service whose
required file is missing will fail until that file exists.

Create the separate Samba password for the existing NixOS user:

```bash
sudo smbpasswd -a julian
```

### 3. Configure the Media Stack

Open Plex at `http://calculon.home:32400/web`, sign in, claim the server, and
add the movie, TV, anime, and music directories under `/mnt/data`.

Configure SABnzbd at `http://calculon.home/sabnzbd`. Confirm both Usenet
servers and the complete/incomplete directories, then copy its API key for
integrations.

Configure the Arr applications:

- Sonarr: add `/mnt/data/tv` and `/mnt/data/anime` as root folders.
- Radarr: add `/mnt/data/movies` as a root folder.
- Lidarr: add `/mnt/data/music` as a root folder.
- Prowlarr: add indexers and connect Sonarr, Radarr, and Lidarr.
- Sonarr and Radarr: add SABnzbd as the download client.
- Bazarr: connect Sonarr and Radarr, then select subtitle languages and
  providers.
- Profilarr: connect Sonarr and Radarr and sync the desired profiles.

### 4. Enable External Integrations

Populate the Doplarr environment file with the resulting Sonarr and Radarr
keys, restart Doplarr, and verify its Discord commands.

Add the Notifiarr API key, restart its container, and configure any desired
Arr, SABnzbd, Plex, and Tautulli checks.

Configure Cloudflare Tunnel ingress in the Cloudflare dashboard for only the
routes intended to be public. The repository supplies the tunnel process but
does not declare its remote ingress policy.

### 5. Create Application Accounts

- Navidrome: create the first administrator account.
- FreshRSS: sign in as `admin` with the configured
  `FRESHRSS_ADMIN_PASSWORD` secret.
- Audiobookshelf: create the first administrator and add audiobook library
  directories.
- Homebox: register the initial account. Afterwards, set
  `HBOX_OPTIONS_ALLOW_REGISTRATION = "false"` in `services/homebox.nix` and
  rebuild if public registration is no longer wanted.
- Tautulli: complete its setup wizard and connect it to the local Plex server.
- Copyparty: verify both configured accounts can access `/data`.

## Rebuilding

From the repository root on Calculon:

```bash
nix-shell
sudo nixos-rebuild dry-run --flake .#calculon
sudo nixos-rebuild switch --flake .#calculon
home-manager switch --flake .#julian@calculon
```

The flake's `deploy-rs` output does not currently define a Calculon node, so the
documented deployment path is a local `nixos-rebuild` over SSH.

Useful health checks after a rebuild:

```bash
sudo systemctl --failed
zpool status
curl --fail http://calculon.home/dashboard >/dev/null
```

## Bare-Metal Reinstallation

> [!CAUTION]
> The Disko command below destroys all data on `/dev/sda` through `/dev/sde`.
> Verify the device mapping with `lsblk` and restore requirements before
> running it. Import an existing `tank` instead of recreating it when preserving
> the media library.

### 1. Boot the Installer

Boot a current minimal NixOS installer, connect Ethernet or configure Wi-Fi,
and become root with `sudo -i`.

### 2. Clone the Configuration

Clone this repository and enter its development shell:

```bash
git clone https://github.com/jpinz/nix-config.git
cd nix-config
nix-shell
```

### 3. Verify the Device Map

Confirm that `/dev/sda` is the system SSD and `/dev/sdb` through `/dev/sde`
are the intended media disks:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
```

### 4. Partition and Mount New Disks

For a completely new installation with no data to preserve, partition, format,
and mount the declared disks:

```bash
nix run github:nix-community/disko -- \
  --mode destroy,format,mount ./hosts/calculon/disko.nix
```

### 5. Install NixOS

Install the host configuration and reboot:

```bash
nixos-install --flake .#calculon
reboot
```

Complete the required secrets and first-run setup above. Secrets and service
databases under `/etc` and `/var/lib` are not recreated by the flake.

[hardware]: https://www.amazon.com/Intel-NUC-Mainstream-Kit-NUC7i5BNH/dp/B01N2UMKZ5
