{ ... }:
{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";

    containers = {
      profilarr = {
        # Profilarr v2.0.9, pinned for reproducible deployments.
        image = "ghcr.io/dictionarry-hub/profilarr@sha256:7a9b5112ff227320d17c65ab643a5d875713e6235991ef04a8e482ec51427902";
        autoStart = true;
        dependsOn = [ "profilarr-parser" ];

        environment = {
          PUID = "1000";
          PGID = "100";
          UMASK = "022";
          TZ = "America/New_York";
          HOST = "0.0.0.0";
          PORT = "6868";
          PARSER_HOST = "127.0.0.1";
          PARSER_PORT = "5000";
        };

        volumes = [
          "/var/lib/profilarr:/config"
        ];

        # Profilarr can reach the native Radarr and Sonarr services on loopback.
        extraOptions = [ "--network=host" ];
      };

      profilarr-parser = {
        # Parser v2.0.9, built from the same revision as Profilarr above.
        image = "ghcr.io/dictionarry-hub/profilarr-parser@sha256:16b22ef6485e135cc660cd511697c637d44649753d02397c9374e1317cfaaf0e";
        autoStart = true;
        extraOptions = [ "--network=host" ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/profilarr 0750 julian users -"
  ];

  # Keep the UI reachable from the LAN and tailnet, but not the public internet.
  networking.firewall.extraCommands = ''
    iptables -I INPUT 1 -p tcp --dport 6868 -j DROP
    iptables -I INPUT 1 -p tcp --dport 6868 -s 100.64.0.0/10 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 6868 -s 192.168.0.0/16 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 6868 -s 10.0.0.0/8 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 6868 -s 172.16.0.0/12 -j ACCEPT
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p tcp --dport 6868 -s 172.16.0.0/12 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 6868 -s 10.0.0.0/8 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 6868 -s 192.168.0.0/16 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 6868 -s 100.64.0.0/10 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 6868 -j DROP 2>/dev/null || true
  '';
}