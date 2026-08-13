{ config, ... }:
{
  systemd.services.hermes-dashboard = {
    description = "Hermes Agent Dashboard";
    after = [
      "hermes-agent.service"
      "network-online.target"
    ];
    wants = [ "network-online.target" ];
    wantedBy = [ ];

    environment = {
      HOME = "/var/lib/hermes";
      HERMES_HOME = "/var/lib/hermes/.hermes";
      HERMES_MANAGED = "true";
    };

    serviceConfig = {
      Type = "simple";
      User = config.services.hermes-agent.user;
      Group = config.services.hermes-agent.group;
      WorkingDirectory = "/var/lib/hermes/workspace";
      EnvironmentFile = [
        "/var/lib/hermes/copilot.env"
        "/var/lib/hermes/dashboard.env"
      ];
      ExecStart = ''
        ${config.services.hermes-agent.package}/bin/hermes dashboard \
          --host 0.0.0.0 \
          --port 9119 \
          --no-open \
          --skip-build
      '';
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0007";

      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = false;
      ReadWritePaths = [ "/var/lib/hermes" ];
    };
  };

  networking.firewall.extraCommands = ''
    iptables -I INPUT 1 -p tcp --dport 9119 -j DROP
    iptables -I INPUT 1 -p tcp --dport 9119 -s 192.168.0.0/16 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 9119 -s 10.0.0.0/8 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 9119 -s 172.16.0.0/12 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 9119 -s 127.0.0.0/8 -j ACCEPT
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p tcp --dport 9119 -s 127.0.0.0/8 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 9119 -s 172.16.0.0/12 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 9119 -s 10.0.0.0/8 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 9119 -s 192.168.0.0/16 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 9119 -j DROP 2>/dev/null || true
  '';
}