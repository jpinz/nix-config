{
  config,
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
    url = "http://127.0.0.1:7878/radarr"
    api_key = "''${RADARR_API_KEY}"
    quality_profile = "1080p Balanced"
    monitor_type = "movieOnly"
    minimum_availability = "announced"

    # TV via Sonarr → /request series
    [[backends]]
    media = "series"

    [backends.config.Sonarr]
    url = "http://127.0.0.1:8989/sonarr"
    api_key = "''${SONARR_API_KEY}"
    quality_profile = "1080p Balanced"
    season_folders = true
    rootfolder = "/mnt/data/tv"

    # Anime via Sonarr → /request anime (same instance, tagged as anime)
    [[backends]]
    media = "anime"

    [backends.config.Sonarr]
    url = "http://127.0.0.1:8989/sonarr"
    api_key = "''${SONARR_API_KEY}"
    quality_profile = "1080p Balanced"
    series_type = "anime"
    season_folders = true
    # Pin anime requests to the dedicated anime library so they never land in
    # the standard /mnt/data/tv tree. Path must match a root folder configured
    # in Sonarr (Settings -> Media Management -> Root Folders).
    rootfolder = "/mnt/data/anime"
  '';
in
{
  sops.secrets = {
    DOPLARR_DISCORD_TOKEN.restartUnits = [ "doplarr.service" ];
    RADARR_API_KEY.restartUnits = [ "doplarr.service" ];
    SONARR_API_KEY.restartUnits = [ "doplarr.service" ];
  };

  sops.templates."doplarr.env".content = ''
    DOPLARR_DISCORD_TOKEN=${config.sops.placeholder.DOPLARR_DISCORD_TOKEN}
    RADARR_API_KEY=${config.sops.placeholder.RADARR_API_KEY}
    SONARR_API_KEY=${config.sops.placeholder.SONARR_API_KEY}
  '';

  # Doplarr — Discord bot for requesting movies and TV through Radarr/Sonarr.
  systemd.services.doplarr = {
    description = "Doplarr - Discord media request bot";
    after = [
      "network-online.target"
      "radarr.service"
      "sonarr.service"
    ];
    wants = [
      "network-online.target"
      "radarr.service"
      "sonarr.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "exec";
      ExecStart = "${doplarr}/bin/doplarr ${configFile}";
      EnvironmentFile = config.sops.templates."doplarr.env".path;
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
