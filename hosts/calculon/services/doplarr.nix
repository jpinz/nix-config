{
  pkgs,
  inputs,
  ...
}:
let
  doplarr = inputs.doplarr.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Non-secret config. Secrets (Discord token + *arr API keys) are pulled from
  # environment variables via ${VAR} substitution at startup and supplied by
  # the EnvironmentFile below, which is kept out of the Nix store.
  configFile = pkgs.writeText "doplarr-config.toml" ''
    discord_token = "''${DOPLARR_DISCORD_TOKEN}"
    log_level = "info"

    # Movies via Radarr → /request movie
    [[backends]]
    media = "movie"

    [backends.config.Radarr]
    url = "http://calculon.home/radarr"
    api_key = "''${RADARR_API_KEY}"
    quality_profile = "HD-1080p"
    monitor_type = "movieOnly"
    minimum_availability = "announced"

    # TV via Sonarr → /request series
    [[backends]]
    media = "series"

    [backends.config.Sonarr]
    url = "http://calculon.home/sonarr"
    api_key = "''${SONARR_API_KEY}"
    quality_profile = "HD-1080p"
    season_folders = true
    rootfolder = "/mnt/data/tv"

    # Anime via Sonarr → /request anime (same instance, tagged as anime)
    [[backends]]
    media = "anime"

    [backends.config.Sonarr]
    url = "http://calculon.home/sonarr"
    api_key = "''${SONARR_API_KEY}"
    quality_profile = "Remux-1080p - Anime"
    series_type = "anime"
    season_folders = true
    # Pin anime requests to the dedicated anime library so they never land in
    # the standard /mnt/data/tv tree. Path must match a root folder configured
    # in Sonarr (Settings -> Media Management -> Root Folders).
    rootfolder = "/mnt/data/anime"
  '';
in
{
  # Doplarr — Discord bot for requesting movies and TV through Radarr/Sonarr.
  #
  # Secrets are read from an EnvironmentFile that must be created manually and
  # kept out of the Nix store (like the cloudflared tunnel token). Create
  # /etc/doplarr/doplarr.env with 0600 perms containing:
  #
  #   DOPLARR_DISCORD_TOKEN=your_discord_bot_token
  #   RADARR_API_KEY=your_radarr_api_key
  #   SONARR_API_KEY=your_sonarr_api_key
  systemd.services.doplarr = {
    description = "Doplarr - Discord media request bot";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "exec";
      ExecStart = "${doplarr}/bin/doplarr ${configFile}";
      EnvironmentFile = "/etc/doplarr/doplarr.env";
      Restart = "on-failure";
      RestartSec = 5;
      DynamicUser = true;

      # Hardening — the bot only makes outbound HTTP requests, no local state.
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
