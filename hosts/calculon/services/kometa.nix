{ config, ... }:
{
  sops.templates."kometa-config.yml" = {
    owner = "root";
    group = "root";
    mode = "0400";
    content = ''
      plex:
        url: http://127.0.0.1:32400
        token: ${config.sops.placeholder.kometa_plex_token}
        timeout: 60
        db_cache: 40
        clean_bundles: false
        empty_trash: false
        optimize: false
        verify_ssl: true

      tmdb:
        apikey: ${config.sops.placeholder.kometa_tmdb_api_key}
        cache_expiration: 60
        language: en

      mdblist:
        apikey: ${config.sops.placeholder.kometa_mdblist_api_key}
        cache_expiration: 60

      libraries:
        Movies:
          collection_files:
            - default: basic
              template_variables:
                limit: 50
                use_separator: false
                visible_library_released: true
                visible_home_released: true
                visible_shared_released: true
            - default: imdb
              template_variables:
                use_lowest: false
                use_separator: false
                visible_library_popular: true
                visible_library_top: true
                visible_home_popular: true
                visible_shared_popular: true
            - default: tmdb
              template_variables:
                limit: 50
                use_top: false
                use_separator: false
                visible_library_trending: true
            - default: letterboxd
              template_variables:
                use_lowest: false
                use_separator: false
                visible_library_popular: true
                visible_library_top: true
                visible_home_popular: true
                visible_shared_popular: true
            - default: streaming
              template_variables:
                data:
                  netflix: Netflix
                  amazon: Prime Video
                  disney: Disney+
                  hulu: Hulu
                  appletv: Apple TV
                  paramount: Paramount+
                  peacock: Peacock
                region: US
                minimum_items: 3
                use_separator: false
                visible_library: true
            - default: universe
              template_variables:
                collection_order: release
                minimum_items: 3
                use_separator: false
            - default: seasonal
              template_variables:
                minimum_items: 3
                use_separator: false
                visible_library: true
                visible_home: true
                visible_shared: true
          overlay_files:
            - default: resolution
            - default: audio_codec
            - default: ratings
              template_variables:
                rating1: imdb
                rating2: mdb_letterboxd
                rating2_image: letterboxd
                rating_alignment: horizontal
                horizontal_position: center
                vertical_position: bottom
                rating1_vertical_align: bottom
                rating1_vertical_offset: 30
                rating2_vertical_align: bottom
                rating2_vertical_offset: 30
        TV Shows:
          collection_files:
            - default: basic
              template_variables:
                limit: 50
                use_separator: false
                visible_library_episodes: true
                visible_home_episodes: true
                visible_shared_episodes: true
            - default: imdb
              template_variables:
                use_separator: false
                visible_library_popular: true
                visible_library_top: true
                visible_home_popular: true
                visible_shared_popular: true
            - default: tmdb
              template_variables:
                limit: 50
                use_airing: false
                use_popular: false
                use_top: false
                use_separator: false
                visible_library_trending: true
            - default: streaming
              template_variables:
                data:
                  netflix: Netflix
                  amazon: Prime Video
                  disney: Disney+
                  hulu: Hulu
                  appletv: Apple TV
                  paramount: Paramount+
                  peacock: Peacock
                region: US
                minimum_items: 3
                use_separator: false
                visible_library: true
            - default: universe
              template_variables:
                collection_order: release
                minimum_items: 3
                use_separator: false
          overlay_files:
            - default: resolution
            - default: audio_codec
            - default: ratings
              template_variables:
                rating1: imdb
                rating2: tmdb
                rating_alignment: horizontal
                horizontal_position: center
                vertical_position: bottom
        Anime:
          collection_files:
            - default: basic
              template_variables:
                limit: 50
                use_separator: false
                visible_library_episodes: true
                visible_home_episodes: true
                visible_shared_episodes: true
            - default: anilist
              template_variables:
                limit: 50
                use_separator: false
                visible_library_season: true
                visible_library_trending: true
                visible_home_trending: true
                visible_shared_trending: true
            - default: streaming
              template_variables:
                data:
                  crunchyroll: Crunchyroll
                  netflix: Netflix
                region: US
                minimum_items: 3
                use_separator: false
                visible_library: true
          overlay_files:
            - default: resolution
            - default: audio_codec
            - default: status
            - default: ratings
              template_variables:
                rating1: imdb
                rating2: tmdb
                rating_alignment: horizontal
                horizontal_position: center
                vertical_position: bottom

      settings:
        cache: true
        cache_expiration: 60
        sync_mode: append
        minimum_items: 2
        delete_below_minimum: false
        delete_not_scheduled: false
        run_order:
          - operations
          - metadata
          - collections
          - overlays
    '';
  };

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.kometa = {
      image = "docker.io/kometateam/kometa:v2.4.8";
      autoStart = true;

      environment.TZ = "America/New_York";
      environment.KOMETA_READ_ONLY_CONFIG = "true";
      volumes = [
        "/var/lib/kometa:/config"
        "${config.sops.templates."kometa-config.yml".path}:/config/config.yml:ro"
      ];

      # Plex runs natively on Calculon, so expose the host loopback to Kometa.
      extraOptions = [ "--network=host" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/kometa 0750 julian users -"
  ];
}
