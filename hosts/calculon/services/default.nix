{ config, ... }:
{
  imports = [
    ./audiobookshelf.nix
    ./caddy.nix
    # ./grafana.nix
    # ./calibre-web.nix
    ./samba.nix
    # ./hd-idle.nix
    ./bazarr.nix
    ./homebox.nix
    ./lidarr.nix
    ./navidrome.nix
    ./plex.nix
    ./prowlarr.nix
    ./radarr.nix
    ./profilarr.nix
    ./rustdesk-server.nix
    ./shelfmark.nix
    ./sonarr.nix
    ./tautulli.nix

    # Enable after migration once their credentials are configured.
    # ./cloudflared.nix
    # ./copyparty.nix
    # ./doplarr.nix
    # ./freshrss.nix
    # ./glance.nix
    # ./notifiarr.nix
    # ./sabnzbd.nix
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
    # 4317 # OpenTelemetry OTLP gRPC ingest (Tempo)
    # 4318 # OpenTelemetry OTLP HTTP ingest (Tempo)
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
  # Plex opens its required ports via services.plex.openFirewall = true
}