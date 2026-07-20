{ ... }:
{
  # OpenTelemetry stack for a self-hosted web app.
  #
  # Point your app's OTLP exporter at calculon:
  #   gRPC: http://calculon.home:4317
  #   HTTP: http://calculon.home:4318
  #
  # The collector fans signals out to purpose-built backends:
  #   traces  -> Tempo
  #   logs    -> Loki
  #   metrics -> Prometheus (native OTLP receiver)
  #
  # NOTE: only components from the *core* otelcol distribution are used
  # (otlp + otlphttp exporters, batch processor). Contrib-only components
  # like `prometheusremotewrite` are intentionally avoided so this works
  # with the default `pkgs.opentelemetry-collector` package.
  services.opentelemetry-collector = {
    enable = true;
    settings = {
      receivers.otlp.protocols = {
        grpc.endpoint = "0.0.0.0:4317";
        http.endpoint = "0.0.0.0:4318";
      };

      processors.batch = { };

      exporters = {
        # Traces -> Tempo (OTLP gRPC)
        "otlp/tempo" = {
          endpoint = "127.0.0.1:4319";
          tls.insecure = true;
        };
        # Logs -> Loki (native OTLP ingest; exporter appends /v1/logs)
        "otlphttp/loki".endpoint = "http://127.0.0.1:3100/otlp";
        # Metrics -> Prometheus (native OTLP receiver; appends /v1/metrics)
        "otlphttp/prometheus".endpoint = "http://127.0.0.1:9090/api/v1/otlp";
      };

      service.pipelines = {
        traces = {
          receivers = [ "otlp" ];
          processors = [ "batch" ];
          exporters = [ "otlp/tempo" ];
        };
        logs = {
          receivers = [ "otlp" ];
          processors = [ "batch" ];
          exporters = [ "otlphttp/loki" ];
        };
        metrics = {
          receivers = [ "otlp" ];
          processors = [ "batch" ];
          exporters = [ "otlphttp/prometheus" ];
        };
      };

      # The collector's own internal metrics. Default is 127.0.0.1:8888,
      # which collides with audiobookshelf; move it to 8889.
      service.telemetry.metrics.readers = [
        {
          pull.exporter.prometheus = {
            host = "127.0.0.1";
            port = 8889;
          };
        }
      ];
    };
  };

  # Metrics backend. Accepts OTLP metrics pushed by the collector and is
  # scraped/queried by Grafana.
  services.prometheus = {
    enable = true;
    port = 9090;
    listenAddress = "127.0.0.1";
    extraFlags = [
      "--web.enable-otlp-receiver" # enables POST /api/v1/otlp/v1/metrics
    ];
    globalConfig.scrape_interval = "15s";
    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [{ targets = [ "127.0.0.1:9090" ]; }];
      }
    ];
  };

  services.tempo = {
    enable = true;
    settings = {
      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3200;
      };

      distributor.receivers.otlp.protocols = {
        grpc.endpoint = "127.0.0.1:4319";
        http.endpoint = "127.0.0.1:4320";
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

  # Logs backend. Single-binary, filesystem-backed Loki with structured
  # metadata enabled (required for OTLP log ingest).
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;

      server = {
        http_listen_address = "127.0.0.1";
        http_listen_port = 3100;
        # Tempo already owns the default gRPC port 9095; pick another.
        grpc_listen_port = 9096;
      };

      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
      };

      schema_config.configs = [
        {
          from = "2024-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config.filesystem.directory = "/var/lib/loki/chunks";

      limits_config = {
        allow_structured_metadata = true;
        retention_period = "168h";
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        retention_enabled = true;
        delete_request_store = "filesystem";
      };
    };
  };

  # Visualization, pre-provisioned with all three datasources.
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
          jsonData = {
            tracesToLogsV2.datasourceUid = "loki";
            tracesToMetrics.datasourceUid = "prometheus";
          };
        }
        {
          name = "Loki";
          type = "loki";
          uid = "loki";
          access = "proxy";
          url = "http://127.0.0.1:3100";
          editable = true;
          jsonData.derivedFields = [
            {
              name = "TraceID";
              matcherRegex = "trace_id=(\\w+)";
              url = "$${__value.raw}";
              datasourceUid = "tempo";
            }
          ];
        }
      ];
    };
  };
}