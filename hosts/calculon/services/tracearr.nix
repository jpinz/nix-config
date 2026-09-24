{ ... }:
{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.tracearr = {
      # Tracearr v2.4.1 supervised, pinned for reproducible deployments.
      image = "ghcr.io/connorgallopo/tracearr@sha256:689af46c10c34ccd0487be71a713323574a8cfd60214d89fee6ddb5f60555eae";
      autoStart = true;

      environment = {
        TZ = "America/New_York";
        LOG_LEVEL = "info";
      };

      # Keep the former Tautulli address while Tracearr listens on 3000 in the
      # container. Its database, cache, application state, and backups persist
      # independently across image updates.
      ports = [ "8181:3000" ];
      volumes = [
        "tracearr-postgres:/data/postgres"
        "tracearr-redis:/data/redis"
        "tracearr-data:/data/tracearr"
        "tracearr-backups:/data/backup"
      ];

      # The supervised image bundles PostgreSQL, TimescaleDB, Redis, and Node.js.
      extraOptions = [
        "--memory=3g"
        "--shm-size=512m"
        "--ulimit=nofile=65536:65536"
      ];
    };
  };
}