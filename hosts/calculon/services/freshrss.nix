{ config, pkgs, ... }:
let
  cfg = config.services.freshrss;
  subscriptions = config.sops.templates."freshrss-subscriptions.opml";
in
{
  sops.secrets = {
    FRESHRSS_ADMIN_PASSWORD = {
      owner = cfg.user;
      restartUnits = [ "freshrss-config.service" ];
    };
    FRESHRSS_404_MEDIA_FEED_KEY = {
      owner = cfg.user;
      restartUnits = [ "freshrss-subscriptions.service" ];
    };
    FRESHRSS_PLATFORMER_FEED_KEY = {
      owner = cfg.user;
      restartUnits = [ "freshrss-subscriptions.service" ];
    };
  };

  sops.templates."freshrss-subscriptions.opml" = {
    owner = cfg.user;
    mode = "0400";
    content = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="2.0">
        <head>
          <title>FreshRSS subscriptions</title>
        </head>
        <body>
          <outline text="xkcd.com" title="xkcd.com" type="rss" xmlUrl="https://xkcd.com/atom.xml" htmlUrl="https://xkcd.com/"/>
          <outline text="Wirecutter: Reviews for the Real World" title="Wirecutter: Reviews for the Real World" type="rss" xmlUrl="http://feeds.feedburner.com/thesweethome/NpUt" htmlUrl="https://www.nytimes.com/wirecutter"/>
          <outline text="Daring Fireball" title="Daring Fireball" type="rss" xmlUrl="https://daringfireball.net/feeds/main" htmlUrl="https://daringfireball.net/"/>
          <outline text="Stratechery by Ben Thompson" title="Stratechery by Ben Thompson" type="rss" xmlUrl="https://stratechery.com/feed/" htmlUrl="https://stratechery.com"/>
          <outline text="Marques Brownlee" title="Marques Brownlee" type="rss" xmlUrl="https://www.youtube.com/feeds/videos.xml?channel_id=UCBJycsmduvYEL83R_U4JriQ" htmlUrl="https://www.youtube.com/channel/UCBJycsmduvYEL83R_U4JriQ"/>
          <outline text="Ars Technica" title="Ars Technica" type="rss" xmlUrl="https://arstechnica.com/feed/" htmlUrl="https://arstechnica.com"/>
          <outline text="Polygon.com" title="Polygon.com" type="rss" xmlUrl="https://www.polygon.com/feed/" htmlUrl="https://www.polygon.com"/>
          <outline text="404 Media" title="404 Media" type="rss" xmlUrl="https://404.feed.press/private?key=${config.sops.placeholder.FRESHRSS_404_MEDIA_FEED_KEY}" htmlUrl="https://www.404media.co/"/>
          <outline text="Platformer" title="Platformer" type="rss" xmlUrl="https://feed.platformer.news/?key=${config.sops.placeholder.FRESHRSS_PLATFORMER_FEED_KEY}" htmlUrl="https://www.platformer.news/"/>
          <outline text="verge" title="verge">
            <outline text="Quick Posts" title="Quick Posts" type="rss" xmlUrl="https://www.theverge.com/rss/quickposts" htmlUrl="https://www.theverge.com"/>
            <outline text="The Verge" title="The Verge" type="rss" xmlUrl="https://www.theverge.com/rss/partner/subscriber-only-full-feed/rss.xml" htmlUrl="https://www.theverge.com"/>
            <outline text="Notepad" title="Notepad" type="rss" xmlUrl="https://www.theverge.com/rss/partner/subscriber-only-notepad/rss.xml" htmlUrl="https://www.theverge.com"/>
            <outline text="Installer" title="Installer" type="rss" xmlUrl="https://www.theverge.com/rss/partner/subscriber-only-installer/rss.xml" htmlUrl="https://www.theverge.com"/>
          </outline>
          <outline text="wired" title="wired">
            <outline text="WIRED" title="WIRED" type="rss" xmlUrl="https://www.wired.com/feed/rss" htmlUrl="https://www.wired.com"/>
            <outline text="Security" title="Security" type="rss" xmlUrl="https://www.wired.com/feed/category/security/latest/rss" htmlUrl="https://www.wired.com"/>
            <outline text="Gear" title="Gear" type="rss" xmlUrl="https://www.wired.com/feed/category/gear/latest/rss" htmlUrl="https://www.wired.com"/>
            <outline text="Science" title="Science" type="rss" xmlUrl="https://www.wired.com/feed/category/science/latest/rss" htmlUrl="https://www.wired.com"/>
            <outline text="Artificial Intelligence" title="Artificial Intelligence" type="rss" xmlUrl="https://www.wired.com/feed/tag/ai/latest/rss" htmlUrl="https://www.wired.com"/>
          </outline>
        </body>
      </opml>
    '';
  };

  services.freshrss = {
    enable = true;
    webserver = "caddy";
    virtualHost = "http://127.0.0.1:8090";
    baseUrl = "https://calculon.jpinzer.me/rss";
    authType = "form";
    passwordFile = config.sops.secrets.FRESHRSS_ADMIN_PASSWORD.path;
    api.enable = true;
  };

  systemd.services.freshrss-subscriptions = {
    description = "Import FreshRSS subscriptions";
    after = [ "freshrss-config.service" ];
    requires = [ "freshrss-config.service" ];
    wantedBy = [ "multi-user.target" ];
    environment.DATA_PATH = cfg.dataDir;
    serviceConfig = {
      Type = "oneshot";
      User = cfg.user;
      Group = config.users.users.${cfg.user}.group;
      UMask = "0077";
    };
    script = ''
      currentHash="$(${pkgs.coreutils}/bin/sha256sum ${subscriptions.path})"
      currentHash="''${currentHash%% *}"
      marker=${cfg.dataDir}/subscriptions.sha256

      if test -r "$marker" && test "$(${pkgs.coreutils}/bin/cat "$marker")" = "$currentHash"; then
        exit 0
      fi

      ${cfg.package}/cli/import-for-user.php \
        --user ${cfg.defaultUser} \
        --filename ${subscriptions.path}
      ${pkgs.coreutils}/bin/printf '%s\n' "$currentHash" > "$marker"
    '';
  };
}