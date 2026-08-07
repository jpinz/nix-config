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

      handle /navidrome* {
        reverse_proxy 127.0.0.1:4533
      }

      handle /shelfmark* {
        reverse_proxy 127.0.0.1:8084
      }

      handle /copyparty* {
        reverse_proxy 127.0.0.1:3923
      }

      handle /dashboard* {
        reverse_proxy 127.0.0.1:8000
      }

      handle /home* {
        reverse_proxy 127.0.0.1:8000
      }

      handle /grafana* {
        reverse_proxy 127.0.0.1:3000
      }

      handle /notifiarr* {
        reverse_proxy 127.0.0.1:5454
      }

      respond "ok" 200
    '';
  };

  # Keep the reverse-proxy reachable on LAN + tailnet, but not from other interfaces.
  networking.firewall.interfaces = {
    "en+".allowedTCPPorts = [ 80 ];
    tailscale0.allowedTCPPorts = [
      80
      443
    ];
  };
}
