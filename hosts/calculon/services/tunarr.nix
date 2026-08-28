{ ... }:
{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.tunarr = {
      # Tunarr v1.3.13, pinned for reproducible deployments.
      image = "docker.io/chrisbenincasa/tunarr@sha256:572e5fb71164aa846610de0e903abe17d43d27d82fb55e3d5565b44d311543ea";
      autoStart = true;

      environment = {
        TZ = "America/New_York";
        TUNARR_LOG_LEVEL = "info";
      };

      # Glance already uses host port 8000. Plex can reach Tunarr on 8001.
      ports = [ "8001:8000" ];
      volumes = [
        "/var/lib/tunarr:/config/tunarr"
        "/mnt/data:/mnt/data:ro"
        "/mnt/archive:/mnt/archive:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/tunarr 0750 root root -"
  ];
}