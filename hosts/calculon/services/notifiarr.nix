{ config, ... }:
{
  # Notifiarr client — bridges this server to notifiarr.com so the media stack
  # and system health can be monitored (and controlled) from Discord.
  #
  # This host otherwise runs everything as native systemd services, but the
  # Notifiarr client is only officially shipped as a container (building it from
  # source drags in an embedded Svelte frontend + code generation that is
  # painful to package and maintain). We run it with **podman** rather than
  # docker so it does not install its own iptables chains that would fight the
  # hand-rolled firewall rules in caddy.nix. Host networking lets it reach the
  # *arr apps on 127.0.0.1 and report real host stats; the UI on :5454 is only
  # reachable via Caddy (/notifiarr) because the firewall never opens that port.
  #
  # The sops-nix notifiarr_env value contains:
  #
  #   DN_API_KEY=your_notifiarr_api_key
  #
  # Get the key at https://notifiarr.com after linking your Discord account and
  # server (Profile page -> "Api Key").
  #
  # Optional per-app service checks / dashboard state live in
  # /etc/notifiarr/notifiarr.conf ([[sonarr]], [[radarr]], [[lidarr]],
  # [[prowlarr]], [sabnzbd], [plex] ... each with name/url/api_key).

  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers.notifiarr = {
      # golift/notifiarr 0.9.5 — pinned by digest for reproducibility.
      # To update: change the version comment and replace the digest with the
      # new linux/amd64 manifest digest from docker.io/golift/notifiarr.
      image = "docker.io/golift/notifiarr@sha256:32aeeebb2bfeac4bf6252cecb40adc3d0100e838cc8f15e7e018e297f5cede03";
      hostname = "calculon";
      autoStart = true;

      environment = {
        TZ = "America/New_York";
        # Serve the client (UI + /api) under /notifiarr so Caddy can proxy it.
        DN_URLBASE = "/notifiarr";
      };

      # DN_API_KEY is supplied here so it never lands in the Nix store.
      environmentFiles = [ config.sops.secrets.notifiarr_env.path ];

      volumes = [
        "/etc/notifiarr:/config" # notifiarr.conf + generated client state
        "/var/run/utmp:/var/run/utmp:ro" # who/uptime for system snapshots
        "/etc/machine-id:/etc/machine-id:ro" # stable machine identity
      ];

      # Host networking: reach the 127.0.0.1 *arr apps and collect accurate host
      # metrics; also binds the UI on :5454 (firewalled, proxied via Caddy).
      extraOptions = [ "--network=host" ];
    };
  };

  # Config/state directory backing the container bind mount above.
  systemd.tmpfiles.rules = [
    "d /etc/notifiarr 0750 root root -"
  ];
}
