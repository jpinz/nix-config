# Calculon

Calculon is an AMD Ryzen 5 3600 system running NixOS. It is the home media
server, download automation host, file server, and home-services host. An
NVIDIA GeForce GTX 1060 6GB is configured for Plex hardware transcoding using
NVIDIA's proprietary kernel module, which is required for Pascal GPUs.

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
| Sonarr | `/sonarr` | TV library automation |
| Sonarr Anime | `/sonarr-anime` | Anime library automation |
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

Application secrets are encrypted in `hosts/calculon/secrets.yaml`. The file is
encrypted to both Calculon's SSH host key and Julian's age key declared in
`.sops.yaml`; only the encrypted file is committed. Edit it on Calculon with:

```bash
nix-shell
sops hosts/calculon/secrets.yaml
sudo nixos-rebuild switch --flake .#calculon
```

Replace every `REPLACE_ME` value before enabling its service. The administrator
identity is stored at `~/.config/sops/age/keys.txt`; keep an off-host backup of
that file with mode `0600`. Calculon decrypts during activation with
`/etc/ssh/ssh_host_ed25519_key`, so preserve that key across hostname changes
and reinstallations.

### SABnzbd

SABnzbd's public settings are declared in `services/sabnzbd.nix`; credentials
and generated API keys are provided by the `sabnzbd_ini` SOPS value. Replace
both provider placeholders before switching the configuration:

```ini
[misc]
api_key = GENERATED_VALUE
nzb_key = GENERATED_VALUE

[servers]
[[news.newshosting.com]]
username = REPLACE_ME
password = REPLACE_ME
[[newshosting.tweaknews.eu]]
username = REPLACE_ME
password = REPLACE_ME
```

The NixOS module merges the existing writable runtime configuration first,
then the declared public settings, then this secret overlay. Public and secret
values therefore remain declarative while SABnzbd can persist operational state
such as quota tracking. Change credentials in SOPS rather than through the web
interface.

### Doplarr

Set up Sonarr and Radarr first, then copy their API keys from **Settings >
General > Security**. Create a Discord application and bot in the Discord
Developer Portal, install it in the target server, and set `doplarr_env` to:

```dotenv
DOPLARR_DISCORD_TOKEN=REPLACE_ME
RADARR_API_KEY=REPLACE_ME
SONARR_API_KEY=REPLACE_ME
SONARR_ANIME_API_KEY=REPLACE_ME
```

Doplarr expects the `1080p Balanced` quality profile in Radarr and both Sonarr
instances. Configure `/mnt/data/tv` in Sonarr and `/mnt/data/anime` in Sonarr
Anime.

### Notifiarr

Link the Notifiarr account to Discord at <https://notifiarr.com>, add the
server, copy the API key from the profile page, and set `notifiarr_env` to:

```dotenv
DN_API_KEY=REPLACE_ME
```

Optional per-application checks can be added to
`/etc/notifiarr/notifiarr.conf`. That file and Notifiarr's generated client
state persist under `/etc/notifiarr`.

### Glance Credentials

Set `glance_env` to the required Sonarr, Radarr, Prowlarr, SABnzbd, and UniFi
values. These credentials were previously committed in `services/glance.nix`,
so rotate the exposed values; moving them into SOPS does not remove them from
Git history. UniFi is an external dependency and is not hosted by Calculon.

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

Replace the SOPS placeholders documented above. Keep a credential-dependent
service disabled until its values are configured.

Create the separate Samba password for the existing NixOS user:

```bash
sudo smbpasswd -a julian
```

### 3. Configure the Media Stack

Open Plex at `http://calculon.home:32400/web`, sign in, claim the server, and
add the movie, TV, anime, and music directories under `/mnt/data`.

Hardware-accelerated transcoding requires Plex Pass. In **Settings > Server >
Transcoder**, enable advanced settings and select **Use hardware acceleration
when available**. After rebuilding and rebooting, verify the driver with
`nvidia-smi`; during a forced transcode, Plex's dashboard should show `(hw)`
next to the video stream.

Open SABnzbd at `http://calculon.home/sabnzbd`. Confirm both SOPS-configured
Usenet servers and the complete/incomplete directories, then use its preserved
API key for integrations.

Configure the Arr applications:

- Sonarr: add `/mnt/data/tv` as its root folder.
- Sonarr Anime: open `http://calculon.home/sonarr-anime` and add
  `/mnt/data/anime` as its root folder.
- Radarr: add `/mnt/data/movies` as a root folder.
- Lidarr: add `/mnt/data/music` as a root folder.
- Prowlarr: add indexers and connect both Sonarr instances, Radarr, and Lidarr.
- Both Sonarr instances and Radarr: add SABnzbd as the download client.
- Bazarr: connect Sonarr and Radarr, then select subtitle languages and
  providers.
- Profilarr: connect both Sonarr instances and Radarr, then sync the desired
  profiles.

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
