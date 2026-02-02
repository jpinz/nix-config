{ config, ... }:
{
  imports = [
    ./audiobookshelf.nix
    ./caddy.nix
    ./calibre-web.nix
    # ./hd-idle.nix
    ./bazarr.nix
    ./glance.nix
    ./homebox.nix
    ./plex.nix
    ./prowlarr.nix
    ./radarr.nix
    ./recyclarr.nix
    ./sabnzbd.nix
    ./sonarr.nix
    ./tautulli.nix
  ];

  users.groups.services.members = with config.services; [
    bazarr.user
    calibre-web.user
    plex.user
    radarr.user
    sabnzbd.user
    sonarr.user
  ];

  systemd.tmpfiles.rules = [
    "d /mnt/downloads/incomplete 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/downloads/complete 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"

    "d /mnt/data/tv 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/data/movies 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
  ];

  # Open firewall ports for locally hosted services
  networking.firewall.allowedTCPPorts = [
    80 # caddy reverse proxy (LAN + Tailscale)
    6767 # bazarr
    7745 # homebox
    8083 # calibre-web
    8181 # tautulli
    8888 # audiobookshelf
    32400 # plex
  ];
  # Plex opens its required ports via services.plex.openFirewall = true
}