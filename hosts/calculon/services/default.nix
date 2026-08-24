{ config, ... }:
{
  imports = [
    # Network and file services
    ./caddy.nix
    ./samba.nix

    # Media acquisition and automation
    ./bazarr.nix
    ./doplarr.nix
    ./lidarr.nix
    ./profilarr.nix
    ./prowlarr.nix
    ./radarr.nix
    ./sabnzbd.nix
    ./sonarr.nix

    # Media libraries and playback
    ./audiobookshelf.nix
    ./navidrome.nix
    ./plex.nix
    ./shelfmark.nix
    ./tautulli.nix

    # Home applications
    ./freshrss.nix
    ./glance.nix
    ./homebox.nix

    # Monitoring and remote access
    ./notifiarr.nix
    ./rustdesk-server.nix
  ];

  users.groups.services.members =
    (with config.services; [
      bazarr.user
      calibre-web.user
      copyparty.user
      lidarr.user
      plex.user
      radarr.user
      sabnzbd.user
      sonarr.user
    ])
    # Give julian access to the shared library trees (e.g. /mnt/data/ebooks),
    # whose files are group-owned by `services`.
    ++ [ config.users.users.julian.name ];

  systemd.tmpfiles.rules = [
    "d /mnt/downloads/incomplete 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/downloads/complete 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"

    "d /mnt/data/tv 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/data/anime 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/data/movies 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/data/music 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/data/ebooks 2770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
  ];

  # Open firewall ports for locally hosted services
  networking.firewall.allowedTCPPorts = [
    80 # caddy reverse proxy (LAN + Tailscale)
    6767 # bazarr
    6868 # profilarr
    7745 # homebox
    8083 # calibre-web
    8084 # shelfmark
    8181 # tautulli
    8686 # lidarr
    8888 # audiobookshelf
    32400 # plex
  ];
}
