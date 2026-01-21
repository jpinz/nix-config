{ config, ... }:
{
  imports = [
    # ./caddy.nix
    # ./hd-idle.nix
    ./plex.nix
    ./prowlarr.nix
    ./radarr.nix
    ./recyclarr.nix
    ./sabnzbd.nix
    ./sonarr.nix
    ./tautulli.nix
  ];

  users.groups.services.members = with config.services; [
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
    9696 # prowlarr
    7878 # radarr
    8080 # sabnzbd (currently bound to ::1)
    8989 # sonarr
    8181 # tautulli
  ];
  # Plex opens its required ports via services.plex.openFirewall = true
}