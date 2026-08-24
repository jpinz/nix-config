{ config, ... }:
{
  sops = {
    defaultSopsFile = ./secrets.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets = {
      doplarr_env = { };
      freshrss_404media_token = { };
      freshrss_password = {
        owner = config.services.freshrss.user;
        group = config.services.freshrss.user;
        mode = "0400";
        restartUnits = [ "freshrss-config.service" ];
      };
      freshrss_platformer_token = { };
      notifiarr_env = { };
      glance_env.restartUnits = [ "glance.service" ];
      sabnzbd_ini = {
        owner = config.services.sabnzbd.user;
        group = config.services.sabnzbd.group;
        mode = "0400";
        restartUnits = [ "sabnzbd.service" ];
      };
    };

    templates."freshrss-subscriptions.opml" = {
      owner = config.services.freshrss.user;
      group = config.services.freshrss.user;
      mode = "0400";
      content = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <opml version="1.0">
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
            <outline text="Polygon.com" title="Polygon.com" type="rss" xmlUrl="https://www.polygon.com/feed/" htmlUrl="https://www.polygon.com/"/>
            <outline text="404 Media" title="404 Media" type="rss" xmlUrl="https://404.feed.press/private?key=${config.sops.placeholder.freshrss_404media_token}" htmlUrl="https://www.404media.co/"/>
            <outline text="Platformer" title="Platformer" type="rss" xmlUrl="https://feed.platformer.news/?key=${config.sops.placeholder.freshrss_platformer_token}" htmlUrl="https://www.platformer.news/"/>
            <outline text="verge" title="verge">
              <outline text="Quick Posts" title="Quick Posts" type="rss" xmlUrl="https://www.theverge.com/rss/quickposts" htmlUrl="https://www.theverge.com/"/>
              <outline text="The Verge" title="The Verge" type="rss" xmlUrl="https://www.theverge.com/rss/partner/subscriber-only-full-feed/rss.xml" htmlUrl="https://www.theverge.com/"/>
              <outline text="Notepad" title="Notepad" type="rss" xmlUrl="https://www.theverge.com/rss/partner/subscriber-only-notepad/rss.xml" htmlUrl="https://www.theverge.com/"/>
              <outline text="Installer" title="Installer" type="rss" xmlUrl="https://www.theverge.com/rss/partner/subscriber-only-installer/rss.xml" htmlUrl="https://www.theverge.com/"/>
            </outline>
            <outline text="wired" title="wired">
              <outline text="WIRED" title="WIRED" type="rss" xmlUrl="https://www.wired.com/feed/rss" htmlUrl="https://www.wired.com/"/>
              <outline text="Security" title="Security" type="rss" xmlUrl="https://www.wired.com/feed/category/security/latest/rss" htmlUrl="https://www.wired.com/"/>
              <outline text="Gear" title="Gear" type="rss" xmlUrl="https://www.wired.com/feed/category/gear/latest/rss" htmlUrl="https://www.wired.com/"/>
              <outline text="Science" title="Science" type="rss" xmlUrl="https://www.wired.com/feed/category/science/latest/rss" htmlUrl="https://www.wired.com/"/>
              <outline text="Artificial Intelligence" title="Artificial Intelligence" type="rss" xmlUrl="https://www.wired.com/feed/tag/ai/latest/rss" htmlUrl="https://www.wired.com/"/>
            </outline>
          </body>
        </opml>
      '';
    };
  };
}
