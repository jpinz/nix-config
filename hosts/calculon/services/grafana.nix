{ ... }:
{
  services.tempo = {
    enable = true;
    settings = {
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3200;
      };

      distributor.receivers.otlp.protocols = {
        grpc.endpoint = "0.0.0.0:4317";
        http.endpoint = "0.0.0.0:4318";
      };

      ingester.max_block_duration = "5m";

      compactor.compaction.block_retention = "168h";

      storage.trace = {
        backend = "local";
        wal.path = "/var/lib/tempo/wal";
        local.path = "/var/lib/tempo/blocks";
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = [ "127.0.0.1:9090" ]; }];
      }
    ];
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        domain = "calculon.home";
        root_url = "http://calculon.home/grafana/";
        serve_from_sub_path = true;
      };

      # Keep the key out of the Nix store.
      security.secret_key = "$__file{/etc/grafana/secret_key}";
    };

    provision.datasources.settings = {
      apiVersion = 1;
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          uid = "prometheus";
          access = "proxy";
          url = "http://127.0.0.1:9090";
          editable = true;
          isDefault = true;
        }
        {
          name = "Tempo";
          type = "tempo";
          uid = "tempo";
          access = "proxy";
          url = "http://127.0.0.1:3200";
          editable = true;
        }
      ];
    };
  };
}