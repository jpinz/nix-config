{ config, ... }:
{
  services.sabnzbd = {
    enable = true;
    group = "services";
    configFile = null;
    allowConfigWrite = true;
    secretFiles = [ config.sops.secrets.sabnzbd_ini.path ];
    settings = {
      misc = {
        bandwidth_max = "70M";
        cache_limit = "1G";
        complete_dir = "/mnt/downloads/complete";
        direct_write = true;
        download_dir = "/mnt/downloads/incomplete";
        pause_on_post_processing = true;
        permissions = "0770";
        host = "127.0.0.1"; # behind Caddy (still reachable on LAN/Tailscale via :80)
        port = 8080;
        url_base = "/sabnzbd";
        host_whitelist = "calculon.home, calculon, localhost, 127.0.0.1, 192.168.1.101";
      };
      servers."news.newshosting.com" = {
        displayname = "Newshosting";
        name = "news.newshosting.com";
        host = "news.newshosting.com";
        port = 563;
        connections = 20;
        use_ssl = true;
        ssl_verify = "strict";
      };
      servers."newshosting.tweaknews.eu" = {
        displayname = "Tweaknews";
        name = "newshosting.tweaknews.eu";
        host = "newshosting.tweaknews.eu";
        port = 443;
        connections = 5;
        priority = 1;
        use_ssl = true;
        ssl_verify = "strict";
      };
    };
  };

  systemd.services.sabnzbd.serviceConfig = {
    CPUWeight = 25;
    IOWeight = 25;
    IOSchedulingClass = "best-effort";
    IOSchedulingPriority = 7;
    MemoryHigh = "2G";
    Nice = 10;
  };
}
