{ pkgs, ... }:
{
  # Overseerr - Request management and media discovery tool for the Plex ecosystem
  # Integrates with Plex, Sonarr, Radarr, and other *arr services
  systemd.services.overseerr = {
    description = "Overseerr - Request management for Plex";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      PORT = "5055";
      CONFIG_DIRECTORY = "/var/lib/overseerr";
      LOG_LEVEL = "info";
    };

    serviceConfig = {
      Type = "exec";
      ExecStart = "${pkgs.overseerr}/bin/overseerr";
      Restart = "on-failure";
      User = "overseerr";
      Group = "services";
      StateDirectory = "overseerr";
      StateDirectoryMode = "0750";
    };
  };

  users.users.overseerr = {
    isSystemUser = true;
    group = "services";
    home = "/var/lib/overseerr";
    createHome = true;
  };

  # Allow access from LAN and Tailscale only
  networking.firewall.extraCommands = ''
    iptables -I INPUT 1 -p tcp --dport 5055 -j DROP
    iptables -I INPUT 1 -p tcp --dport 5055 -s 100.64.0.0/10 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 5055 -s 192.168.0.0/16 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 5055 -s 10.0.0.0/8 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 5055 -s 172.16.0.0/12 -j ACCEPT
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p tcp --dport 5055 -s 172.16.0.0/12 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 5055 -s 10.0.0.0/8 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 5055 -s 192.168.0.0/16 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 5055 -s 100.64.0.0/10 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 5055 -j DROP 2>/dev/null || true
  '';
}
