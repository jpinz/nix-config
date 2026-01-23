{ ... }:
{
  services.caddy = {
    enable = true;

    # Plain HTTP; avoids ACME/Let's Encrypt attempts for `.home` names.
    virtualHosts."http://:80".extraConfig = ''
      encode zstd gzip

      handle /sonarr* {
        reverse_proxy 127.0.0.1:8989
      }

      handle /radarr* {
        reverse_proxy 127.0.0.1:7878
      }

      handle /prowlarr* {
        reverse_proxy 127.0.0.1:9696
      }

      handle /sabnzbd* {
        reverse_proxy 127.0.0.1:8080
      }

      respond "ok" 200
    '';
  };

  # Keep the reverse-proxy reachable on LAN + tailnet, but not from the public internet.
  # (iptables rules are inserted at the top of INPUT so they take precedence.)
  networking.firewall.extraCommands = ''
    iptables -I INPUT 1 -p tcp --dport 80 -j DROP
    iptables -I INPUT 1 -p tcp --dport 80 -s 100.64.0.0/10 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 80 -s 192.168.0.0/16 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 80 -s 10.0.0.0/8 -j ACCEPT
    iptables -I INPUT 1 -p tcp --dport 80 -s 172.16.0.0/12 -j ACCEPT
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p tcp --dport 80 -s 172.16.0.0/12 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 10.0.0.0/8 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 192.168.0.0/16 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 100.64.0.0/10 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -j DROP 2>/dev/null || true
  '';
}
