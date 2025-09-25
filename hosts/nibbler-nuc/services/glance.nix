{ lib, ... }:
{
  services.glance = {
    enable = true;
    settings = {
      server = {
        host = "nibbler.local";
        port = 5678;
      };
      pages = [
        {
          name = "Home";
          "head-widgets" = [
            {
              type = "search";
              "search-engine" = "bing";
              bangs = [
                {
                  title = "YouTube";
                  shortcut = "!yt";
                  url = "https://www.youtube.com/results?search_query={QUERY}";
                }
              ];
            }
          ];
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                  "first-day-of-week" = "sunday";
                }
                {
                  type = "twitch-channels";
                  channels = [
                    "paymoneywubby"
                    "northernlion"
                    "squeex"
                    "atrioc"
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "group";
                  widgets = [
                    {
                      type = "hacker-news";
                    }
                    {
                      type = "rss";
                      title = "The Verge";
                      "title-url" = "https://www.theverge.com";
                      "collapse-after" = 5;
                      cache = "12h";
                      feeds = [
                        {
                          url = "https://www.theverge.com/rss/partner/subscriber-only-full-feed/rss.xml";
                          title = "The Verge";
                        }
                      ];
                    }
                    {
                      type = "rss";
                      title = "404 Media";
                      "title-url" = "https://www.404media.co";
                      "collapse-after" = 5;
                      cache = "12h";
                      feeds = [
                        {
                          url = "https://www.404media.co/rss/";
                          title = "404 Media";
                        }
                      ];
                    }
                    {
                      type = "rss";
                      title = "Wired";
                      "title-url" = "https://www.wired.com/";
                      "collapse-after" = 5;
                      cache = "12h";
                      feeds = [
                        {
                          url = "https://www.wired.com/feed/rss";
                          title = "Wired";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "videos";
                  channels = [
                    "UCXuqSBlHAE6Xw-yeJA0Tunw"
                    "UCR-DXc1voovS8nhAvccRZhg"
                    "UCsBjURrPoezykLs9EqgamOA"
                    "UCBJycsmduvYEL83R_U4JriQ"
                    "UCHnyfMqiRRG1u-2MsSQLbXA"
                  ];
                }
                {
                  type = "group";
                  widgets = [
                    {
                      type = "reddit";
                      subreddit = "magictcg";
                    }
                    {
                      type = "reddit";
                      subreddit = "boston";
                      "show-thumbnails" = true;
                    }
                    {
                      type = "reddit";
                      subreddit = "LivestreamFail";
                      "show-flairs" = true;
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = {
                    _secret = "/var/lib/secrets/glance/location";
                  };
                  units = "imperial";
                  "hour-format" = "12h";
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "SPY";
                      name = "S&P 500";
                    }
                    {
                      symbol = "MSFT";
                      name = "Microsoft";
                    }
                  ];
                }
                {
                  type = "releases";
                  cache = "1d";
                  repositories = [
                    "glanceapp/glance"
                    "dependabot/dependabot-core"
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ 5678 ];
  };
}
