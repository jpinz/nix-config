# Calculon

Calculon is an AMD Ryzen 5 3600 system running NixOS. It is the home media
server, download automation host, file server, and home-services host. An
NVIDIA RTX 2060 Super is configured for hardware transcoding.

## Architecture

- Hostname during migration: `nixos`; change it to `calculon` after retiring the
  old host
- Remote administration: SSH on port `2222`, public-key authentication only
- Private remote access: Tailscale
- Public access: selected routes through a Cloudflare Tunnel; ingress rules are
  managed in Cloudflare, not in this repository
- Local reverse proxy: Caddy on port `80`, restricted to private LAN and
  Tailscale address ranges
- Service account model: media services share the `services` group so they can
  move files between the download and library directories

### Storage

The system SSD retains the ext4 installation created by the NixOS installer.
Disko manages only the three data disks and assumes these exact stable device
IDs:

<!-- markdownlint-disable MD013 -->

| Devices | Pool/filesystem | Layout | Mount point | Purpose |
| --- | --- | --- | --- | --- |
| Samsung SSD `S4PGNG0KC19095L` | ext4 | Installer-managed | `/` | Operating system and service state |
| WDC `7SGH1MDC`, `1EHVGXHZ`, `7SGGTZ9C` | `tank` | Three-disk RAID-Z1 | `/mnt/data` | Media library |

<!-- markdownlint-enable MD013 -->

`tank` uses Zstandard compression with access-time updates disabled. The
configuration creates these shared directories with group-writable, setgid
permissions:

```text
/mnt/downloads/{complete,incomplete}
/mnt/data/{tv,anime,movies,music,ebooks}
```

`/mnt/downloads` is on the system SSD; only `/mnt/data` is on `tank`. RAID-Z is
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

Secrets are created directly on Calculon and must not be committed to this
repository. Create the directories and files before starting the affected
services. Replace every placeholder below.

### Cloudflare Tunnel

Obtain the tunnel token from the Cloudflare Zero Trust dashboard:

```bash
sudo install -d -m 0755 /etc/cloudflared
sudo install -m 0600 /dev/null /etc/cloudflared/tunnel-token
sudoedit /etc/cloudflared/tunnel-token
sudo systemctl restart cloudflared-tunnel
```

The file contains only the tunnel token, with no variable name.

### Copyparty Accounts

Copyparty reads one plain-text password from each file. Its service user must be
able to read them through the shared `services` group:

```bash
sudo install -d -m 0750 -o root -g services /etc/copyparty
sudo install -m 0640 -o root -g services /dev/null /etc/copyparty/julian-password
sudo install -m 0640 -o root -g services /dev/null /etc/copyparty/david-password
sudoedit /etc/copyparty/julian-password
sudoedit /etc/copyparty/david-password
sudo systemctl restart copyparty
```

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

Set up Sonarr and Radarr first, then copy their API keys from **Settings >
General > Security**. Create a Discord application and bot in the Discord
Developer Portal, install it in the target server, and add its token here:

```bash
sudo install -d -m 0755 /etc/doplarr
sudo install -m 0600 /dev/null /etc/doplarr/doplarr.env
sudoedit /etc/doplarr/doplarr.env
```

```dotenv
DOPLARR_DISCORD_TOKEN=REPLACE_ME
RADARR_API_KEY=REPLACE_ME
SONARR_API_KEY=REPLACE_ME
```

```bash
sudo systemctl restart doplarr
```

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

Glance currently has the Sonarr, Radarr, Prowlarr, SABnzbd, UniFi, and Immich
API credentials embedded in `services/glance.nix`. They enter the Nix store and
Git history, so they must not be treated as secret. Rotate those credentials
and move them to an out-of-store environment file before sharing this
repository or host configuration. UniFi and Immich are external dependencies;
they are not hosted by Calculon.

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

Create the secret files documented above. A service whose required file is
missing will fail until that file exists.

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

## Replacement-Hardware Installation

> [!CAUTION]
> The Disko command below destroys all data on the three explicitly declared
> 8 TB data disks. It does not repartition the system SSD. Verify every stable
> device ID and restore requirement before running it.

### 1. Install and Boot NixOS

Install a minimal NixOS system on the SSD, boot it, and enable SSH. The checked-in
hardware configuration contains UUIDs from this installation and must be
regenerated if the SSD is reinstalled or replaced.

### 2. Clone the Configuration

Clone this repository and enter its development shell:

```bash
git clone https://github.com/jpinz/nix-config.git
cd nix-config
nix-shell
```

### 3. Verify the Device Map

Confirm the model, serial number, and `/dev/disk/by-id` link for every disk:

```bash
lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE,MOUNTPOINTS
ls -l /dev/disk/by-id/ata-*
```

### 4. Bootstrap ZFS

Before creating the pool from a stock NixOS installation, add these settings to
`/etc/nixos/configuration.nix`:

```nix
boot.supportedFilesystems = [ "zfs" ];
networking.hostId = "c1f22144";
```

Boot into the resulting generation and verify that the ZFS module and tools are
available:

```bash
sudo nixos-rebuild boot
sudo reboot
sudo modprobe zfs
command -v zpool
```

### 5. Create and Mount a New Tank

After confirming that all three existing XFS filesystems are disposable,
partition, format, and mount only the data disks declared in Disko:

```bash
sudo nix --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko -- \
  --mode destroy,format,mount ./hosts/calculon/disko.nix
```

### 6. Activate Calculon

Activate the host configuration and reboot. Services requiring credentials
remain disabled until their SOPS, environment, or password files are configured:

```bash
sudo nixos-rebuild switch --flake .#calculon
reboot
```

Complete the required secrets and first-run setup above. Secrets and service
databases under `/etc` and `/var/lib` are not recreated by the flake.

### 7. Complete the Cutover

After the old host is powered off permanently, change
`networking.hostName` from `nixos` to `calculon`, rebuild, and update the DHCP or
DNS reservation for `calculon.home`. Keep the replacement host's ZFS host ID
`c1f22144` unchanged.
