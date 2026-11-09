{ config, ... }:
{
  services.dawarich = {
    enable = true;
    configureNginx = false;
    localDomain = "calculon.home";
    webPort = 3000;
    environment = {
      APPLICATION_HOSTS = "localhost,127.0.0.1,::1,calculon,calculon.home";
      APPLICATION_PROTOCOL = "http";
    };
  };

  # Allow private IPv4 sources without opening the port globally.
  networking.firewall.extraCommands = ''
    for source in 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16 100.64.0.0/10; do
      iptables -A nixos-fw -p tcp --dport ${toString config.services.dawarich.webPort} \
        -s "$source" -j nixos-fw-accept
    done
  '';
}
