{ ... }:
{
  services.caddy = {
    enable = true;

    # Shared route configuration
    globalConfig = ''
      servers {
        metrics
      }
    '';

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

      handle /lidarr* {
        reverse_proxy 127.0.0.1:8686
      }

      handle /music* {
        uri replace /music /lidarr
        reverse_proxy 127.0.0.1:8686
      }

      handle /movies* {
        uri replace /movies /radarr
        reverse_proxy 127.0.0.1:7878
      }

      handle /tv* {
        uri replace /tv /sonarr
        reverse_proxy 127.0.0.1:8989
      }

      handle /ebooks* {
        uri replace /ebooks /calibre
        reverse_proxy 127.0.0.1:8083 {
          header_up X-Script-Name /calibre
        }
      }

      handle /calibre* {
        reverse_proxy 127.0.0.1:8083 {
          header_up X-Script-Name /calibre
        }
      }

      handle /audiobooks* {
        uri replace /audiobooks /audiobookshelf
        reverse_proxy 127.0.0.1:8888
      }

      handle /audiobookshelf* {
        reverse_proxy 127.0.0.1:8888
      }

      handle /dashboard* {
        reverse_proxy 127.0.0.1:8000
      }

      handle /home* {
        reverse_proxy 127.0.0.1:8000
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
    iptables -I INPUT 1 -p tcp --dport 443 -j DROP
    iptables -I INPUT 1 -p tcp --dport 443 -s 100.64.0.0/10 -j ACCEPT
  '';

  networking.firewall.extraStopCommands = ''
    iptables -D INPUT -p tcp --dport 443 -s 100.64.0.0/10 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 443 -j DROP 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 172.16.0.0/12 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 10.0.0.0/8 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 192.168.0.0/16 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -s 100.64.0.0/10 -j ACCEPT 2>/dev/null || true
    iptables -D INPUT -p tcp --dport 80 -j DROP 2>/dev/null || true
  '';
}
