{ ... }:
{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.tracearr = {
      # Tracearr v2.2.3 supervised, pinned for reproducible deployments.
      image = "ghcr.io/connorgallopo/tracearr@sha256:fd86c819e5bfa22bc4bbae8d4744d867dd5be42367a6b52d13e82ddb250ecd60";
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