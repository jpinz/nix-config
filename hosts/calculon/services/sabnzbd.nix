{
  services.sabnzbd = {
    enable = true;
    group = "services";
    secretFiles = [ "/var/lib/sabnzbd/secrets.ini" ];
    settings = {
      misc = {
        complete_dir = "/mnt/downloads/complete";
        download_dir = "/mnt/downloads/incomplete";
        permissions = "0770";
        host = "127.0.0.1"; # behind Caddy (still reachable on LAN/Tailscale via :80)
        port = 8080;
        url_base = "/sabnzbd";
        host_whitelist = "calculon.home, calculon, localhost, 127.0.0.1, 192.168.1.75";
      };
      servers."news.newshosting.com" = {
        displayname = "Newshosting";
        name = "news.newshosting.com";
        host = "news.newshosting.com";
        port = 563;
        connections = 50;
        use_ssl = true;
        ssl_verify = "strict";
      };
      servers."newshosting.tweaknews.eu" = {
        displayname = "Tweaknews";
        name = "newshosting.tweaknews.eu";
        host = "newshosting.tweaknews.eu";
        port = 443;
        connections = 50;
        use_ssl = true;
        ssl_verify = "strict";
      };
    };
  };
}
