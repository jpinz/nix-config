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
        host = "::1";
        port = 8080;
        url_base = "/sabnzbd";
        host_whitelist = "calculon.home, calculon, 192.168.1.75";
      };
      servers."news.newshosting.com" = {
        displayname = "Newshosting";
        name = "news.newshosting.com";
        host = "news.newshosting.com";
        port = 564;
        connections = 50;
        use_ssl = true;
        ssl_verify = "strict";
      };
      servers."newshosting.tweaknews.eu" = {
        displayname = "Newshosting";
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
