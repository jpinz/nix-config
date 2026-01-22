{
  services.glance = {
    enable = true;
    settings = {
      server = {
        host = "0.0.0.0";
        port = 8000;
      };
      branding = {
        logo-text = "Calculon";
        hide-footer = true;
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "clock";
                  hour-format = "24h";
                }
                {
                  type = "calendar";
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      title = "Media";
                      links = [
                        {
                          title = "Plex";
                          url = "http://calculon.home:32400/web";
                          icon = "si:plex";
                        }
                        {
                          title = "Tautulli";
                          url = "http://calculon.home:8181";
                          icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/tautulli.svg";
                        }
                      ];
                    }
                    {
                      title = "Downloads";
                      links = [
                        {
                          title = "SABnzbd";
                          url = "http://calculon.home:8080/sabnzbd";
                          icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg";
                        }
                      ];
                    }
                    {
                      title = "*arr Stack";
                      links = [
                        {
                          title = "Sonarr";
                          url = "http://calculon.home:8989/sonarr";
                          icon = "si:sonarr";
                        }
                        {
                          title = "Radarr";
                          url = "http://calculon.home:7878/radarr";
                          icon = "si:radarr";
                        }
                        {
                          title = "Prowlarr";
                          url = "http://calculon.home:9696";
                          icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg";
                        }
                      ];
                    }
                  ];
                }
                {
                  type = "twitch-channels";
                  channels = [
                    "northernlion"
                    "squeex"
                    "atrioc"
                    "ludwig"
                    "paymoneywubby"
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "group";
                  style = "tabs-static";
                  widgets = [
                    {
                      type = "hacker-news";
                      title = "Hacker News";
                      limit = 15;
                      collapse-after = 5;
                    }
                    {
                      type = "rss";
                      title = "The Verge";
                      style = "detailed-list";
                      limit = 15;
                      collapse-after = 5;
                      feeds = [
                        {
                          url = "https://www.theverge.com/rss/index.xml";
                        }
                      ];
                    }
                    {
                      type = "rss";
                      title = "404 Media";
                      style = "detailed-list";
                      limit = 15;
                      collapse-after = 5;
                      feeds = [
                        {
                          url = "https://www.404media.co/rss/";
                        }
                      ];
                    }
                    {
                      type = "reddit";
                      title = "/r/homeassistant";
                      subreddit = "homeassistant";
                      style = "vertical-cards";
                      limit = 15;
                      collapse-after = 5;
                    }
                    {
                      type = "reddit";
                      title = "/r/selfhosted";
                      subreddit = "selfhosted";
                      style = "vertical-cards";
                      limit = 15;
                      collapse-after = 5;
                    }
                  ];
                }
                # SABnzbd Status Widget
                {
                  type = "custom-api";
                  title = "SABnzbd";
                  cache = "30s";
                  url = "http://calculon.home:8080/sabnzbd/api?output=json&apikey=\${SABNZBD_API_KEY}&mode=queue";
                  title-url = "http://calculon.home:8080/sabnzbd";
                  headers = {
                    Accept = "application/json";
                  };
                  template = ''
                    <div class="flex gap-15">
                      <div class="flex-1">
                        <div class="size-h6">SPEED</div>
                        <div class="color-highlight size-h3">{{ if eq (.JSON.String "queue.status") "Downloading" }}{{ .JSON.String "queue.speed" }}B/s{{ else }}Paused{{ end }}</div>
                      </div>
                      <div class="flex-1">
                        <div class="size-h6">TIME LEFT</div>
                        <div class="color-highlight size-h3">{{ if eq (.JSON.String "queue.status") "Downloading" }}{{ .JSON.String "queue.timeleft" }}{{ else }}--:--:--{{ end }}</div>
                      </div>
                      <div class="flex-1">
                        <div class="size-h6">QUEUE</div>
                        <div class="color-highlight size-h3">{{ .JSON.Int "queue.noofslots" }} items</div>
                      </div>
                      <div class="flex-1">
                        <div class="size-h6">SIZE</div>
                        <div class="color-highlight size-h3">{{ .JSON.Float "queue.mb" | printf "%.1f" }}MB</div>
                      </div>
                    </div>
                  '';
                }
                # Prowlarr Indexers Widget
                {
                  type = "custom-api";
                  title = "Prowlarr Indexers";
                  cache = "5m";
                  title-url = "http://calculon.home:9696";
                  options = {
                    url = "http://calculon.home:9696";
                    base-url = "http://calculon.home:9696";
                    api-key = "\${PROWLARR_API_KEY}";
                    collapse-after = 5;
                  };
                  template = ''
                    {{ $apiBaseUrl := .Options.StringOr "base-url" "" }}
                    {{ $key := .Options.StringOr "api-key" "" }}
                    {{ $url := .Options.StringOr "url" "" }}
                    {{ $collapseAfter := .Options.IntOr "collapse-after" 5 }}

                    {{ $indexUrl := printf "%s/api/v1/indexer" $apiBaseUrl }}
                    {{ $indexData := newRequest $indexUrl
                      | withHeader "Accept" "application/json"
                      | withHeader "X-Api-Key" $key
                      | getResponse }}

                    {{ if eq $indexData.Response.StatusCode 200 }}
                      <ul class="list list-gap-10 collapsible-container" data-collapse-after="{{ $collapseAfter }}">
                        {{ range $indexData.JSON.Array "" }}
                          {{ $isEnabled := .String "enable" }}
                          <li class="flex items-center gap-12">
                            <a href="{{ $url }}" target="_blank" class="size-title-dynamic color-highlight text-truncate block grow">{{ .String "name" }}</a>
                            <span style="text-transform: capitalize; background: var(--color-background); padding: 0.2rem 0.75rem; border: 1px solid var(--color-widget-content-border); border-radius: var(--border-radius); font-size: var(--font-size-tiny);">{{ .String "privacy" }}</span>
                            {{ if eq $isEnabled "true" }}
                              <span class="color-positive">●</span>
                            {{ else }}
                              <span class="color-negative">●</span>
                            {{ end }}
                          </li>
                        {{ end }}
                      </ul>
                    {{ else }}
                      <p>Failed to fetch data</p>
                    {{ end }}
                  '';
                }
                {
                  type = "monitor";
                  title = "Services";
                  cache = "1m";
                  sites = [
                    {
                      title = "Plex";
                      url = "http://calculon.home:32400/web";
                      icon = "si:plex";
                    }
                    {
                      title = "Sonarr";
                      url = "http://calculon.home:8989/sonarr";
                      icon = "si:sonarr";
                    }
                    {
                      title = "Radarr";
                      url = "http://calculon.home:7878/radarr";
                      icon = "si:radarr";
                    }
                    {
                      title = "Prowlarr";
                      url = "http://calculon.home:9696";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg";
                    }
                    {
                      title = "SABnzbd";
                      url = "http://calculon.home:8080/sabnzbd";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg";
                    }
                    {
                      title = "Tautulli";
                      url = "http://calculon.home:8181";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/tautulli.svg";
                    }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                # Sonarr Upcoming Widget
                {
                  type = "custom-api";
                  title = "Upcoming TV";
                  title-url = "http://calculon.home:8989/sonarr";
                  cache = "15m";
                  options = {
                    base-url = "http://calculon.home:8989/sonarr";
                    api-key = "\${SONARR_API_KEY}";
                    collapse-after = 5;
                  };
                  template = ''
                    {{ $baseUrl := .Options.StringOr "base-url" "" }}
                    {{ $apiKey := .Options.StringOr "api-key" "" }}
                    {{ $collapseAfter := .Options.IntOr "collapse-after" 5 }}

                    {{ $calendarUrl := printf "%s/api/v3/calendar?start=%s&end=%s" $baseUrl (now | formatTime "2006-01-02") ((now.Add (duration "168h")) | formatTime "2006-01-02") }}
                    {{ $calendarData := newRequest $calendarUrl
                      | withHeader "X-Api-Key" $apiKey
                      | getResponse }}

                    {{ if eq $calendarData.Response.StatusCode 200 }}
                      {{ $episodes := $calendarData.JSON.Array "" }}
                      {{ if eq (len $episodes) 0 }}
                        <p class="color-subdue">No upcoming episodes</p>
                      {{ else }}
                        <ul class="list list-gap-10 collapsible-container" data-collapse-after="{{ $collapseAfter }}">
                          {{ range $episodes }}
                            <li>
                              <div class="flex justify-between">
                                <span class="color-highlight text-truncate">{{ .String "series.title" }} - S{{ .Int "seasonNumber" }}E{{ .Int "episodeNumber" }}</span>
                                <span class="color-primary shrink-0" style="margin-left: 0.5rem;">{{ .String "airDateUtc" | parseTime "2006-01-02T15:04:05Z" | formatTime "Jan 2" }}</span>
                              </div>
                              <div class="color-subdue text-truncate size-h6">{{ .String "title" }}</div>
                            </li>
                          {{ end }}
                        </ul>
                      {{ end }}
                    {{ else }}
                      <p class="color-negative">Failed to fetch Sonarr data</p>
                    {{ end }}
                  '';
                }
                # Radarr Upcoming Widget
                {
                  type = "custom-api";
                  title = "Upcoming Movies";
                  title-url = "http://calculon.home:7878/radarr";
                  cache = "15m";
                  options = {
                    base-url = "http://calculon.home:7878/radarr";
                    api-key = "\${RADARR_API_KEY}";
                    collapse-after = 5;
                  };
                  template = ''
                    {{ $baseUrl := .Options.StringOr "base-url" "" }}
                    {{ $apiKey := .Options.StringOr "api-key" "" }}
                    {{ $collapseAfter := .Options.IntOr "collapse-after" 5 }}

                    {{ $calendarUrl := printf "%s/api/v3/calendar?start=%s&end=%s" $baseUrl (now | formatTime "2006-01-02") ((now.Add (duration "720h")) | formatTime "2006-01-02") }}
                    {{ $calendarData := newRequest $calendarUrl
                      | withHeader "X-Api-Key" $apiKey
                      | getResponse }}

                    {{ if eq $calendarData.Response.StatusCode 200 }}
                      {{ $movies := $calendarData.JSON.Array "" }}
                      {{ if eq (len $movies) 0 }}
                        <p class="color-subdue">No upcoming movies</p>
                      {{ else }}
                        <ul class="list list-gap-10 collapsible-container" data-collapse-after="{{ $collapseAfter }}">
                          {{ range $movies }}
                            <li>
                              <div class="color-highlight text-truncate">{{ .String "title" }}</div>
                              <div class="flex justify-between">
                                <span class="color-subdue">{{ .Int "year" }}</span>
                                <span class="color-primary">{{ .String "digitalRelease" | parseTime "2006-01-02T15:04:05Z" | formatTime "Jan 2" }}</span>
                              </div>
                            </li>
                          {{ end }}
                        </ul>
                      {{ end }}
                    {{ else }}
                      <p class="color-negative">Failed to fetch Radarr data</p>
                    {{ end }}
                  '';
                }
                # Unifi Widget
                {
                  type = "custom-api";
                  title = "Unifi";
                  cache = "1m";
                  allow-insecure = true;
                  url = "https://\${UNIFI_CONSOLE_IP}/proxy/network/api/stat/sites";
                  headers = {
                    X-API-KEY = "\${UNIFI_API_KEY}";
                    Accept = "application/json";
                  };
                  template = ''
                    <style>
                      .list-horizontal-text.no-bullets-unifi > *:not(:last-child)::after {
                          content: none !important;
                      }
                      .list-horizontal-text.no-bullets-unifi > *:not(:last-child) {
                        margin-right: 1em;
                      }
                    </style>
                    {{ range .JSON.Array "data" }}
                      <div style="display:flex; align-items:center; gap:12px;">
                        <div style="width:40px; height:40px; flex-shrink:0; display:flex; justify-content:center; align-items:center; overflow:hidden;">
                          <img src="https://cdn.jsdelivr.net/gh/selfhst/icons/svg/ubiquiti-unifi-light.svg" width="24" height="24" style="object-fit:contain;">
                        </div>
                        <div style="flex-grow:1; min-width:0;">
                          <a class="size-h4 block text-truncate color-highlight">
                            {{ .String "health.#(subsystem=wan).gw_name" }}
                            {{ if eq (.String "health.#(subsystem=wan).status") "ok" }}
                            <span style="width: 8px; height: 8px; border-radius: 50%; background-color: var(--color-positive); display: inline-block; vertical-align: middle;"></span>
                            {{ else }}
                            <span style="width: 8px; height: 8px; border-radius: 50%; background-color: var(--color-negative); display: inline-block; vertical-align: middle;"></span>
                            {{ end }}
                          </a>
                          <ul class="list-horizontal-text no-bullets-unifi">
                            <li>
                              <p style="display:inline-flex;align-items:center;">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" style="height:1em;vertical-align:middle;margin-right:0.5em;">
                                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
                                </svg>
                                {{ printf "%.1f" (div (.Float "health.#(subsystem=wan).gw_system-stats.uptime") 86400) }}d
                              </p>
                            </li>
                            <li>
                              <p style="display:inline-flex;align-items:center;">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" style="height:1em;vertical-align:middle;margin-right:0.5em;">
                                  <path fill="none" d="M0 0h24v24H0z"></path><path d="M7.77 6.76 6.23 5.48.82 12l5.41 6.52 1.54-1.28L3.42 12l4.35-5.24zM7 13h2v-2H7v2zm10-2h-2v2h2v-2zm-6 2h2v-2h-2v2zm6.77-7.52-1.54 1.28L20.58 12l-4.35 5.24 1.54 1.28L23.18 12l-5.41-6.52z"></path>
                                </svg>
                                {{ .Int "health.#(subsystem=lan).num_user" }} wired
                              </p>
                            </li>
                            <li>
                              <p style="display:inline-flex;align-items:center;">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" style="height:1em;vertical-align:middle;margin-right:0.5em;">
                                  <path d="M12 6c3.537 0 6.837 1.353 9.293 3.809l1.414-1.414C19.874 5.561 16.071 4 12 4c-4.071.001-7.874 1.561-10.707 4.395l1.414 1.414C5.163 7.353 8.463 6 12 6zm5.671 8.307c-3.074-3.074-8.268-3.074-11.342 0l1.414 1.414c2.307-2.307 6.207-2.307 8.514 0l1.414-1.414z"></path><path d="M20.437 11.293c-4.572-4.574-12.301-4.574-16.873 0l1.414 1.414c3.807-3.807 10.238-3.807 14.045 0l1.414-1.414z"></path><circle cx="12" cy="18" r="2"></circle>
                                </svg>
                                {{ .Int "health.#(subsystem=wlan).num_user" }} wifi
                              </p>
                            </li>
                          </ul>
                        </div>
                      </div>
                      <div class="margin-block-2" style="margin-top: 1em">
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
                          <div>
                            <div class="size-h5">Latency</div>
                            <div class="size-h3 color-highlight">{{ .Int "health.#(subsystem=wan).uptime_stats.WAN.latency_average" }}<span class="color-base"> ms</span></div>
                          </div>
                          <div>
                            <div class="size-h5">WAN IP</div>
                            <div class="size-h3 color-highlight">{{ .String "health.#(subsystem=wan).wan_ip" }}</div>
                          </div>
                          <div>
                            <div class="size-h5">Gateway CPU</div>
                            <div class="size-h3 color-highlight">{{ .String "health.#(subsystem=wan).gw_system-stats.cpu" }}<span class="color-base"> %</span></div>
                          </div>
                          <div>
                            <div class="size-h5">Gateway RAM</div>
                            <div class="size-h3 color-highlight">{{ .String "health.#(subsystem=wan).gw_system-stats.mem" }}<span class="color-base"> %</span></div>
                          </div>
                        </div>
                      </div>
                    {{ end }}
                  '';
                }
                # xkcd Widget
                {
                  type = "custom-api";
                  title = "xkcd";
                  cache = "2h";
                  url = "https://xkcd.com/info.0.json";
                  template = ''
                    <div style="text-align: center;">
                      <div class="color-highlight size-h4" style="margin-bottom: 0.5rem;">{{ .JSON.String "title" }}</div>
                      <img src="{{ .JSON.String "img" }}" alt="{{ .JSON.String "alt" }}" title="{{ .JSON.String "alt" }}" style="max-width: 100%; border-radius: var(--border-radius);">
                    </div>
                  '';
                }
                {
                  type = "releases";
                  title = "Software Releases";
                  repositories = [
                    "Sonarr/Sonarr"
                    "Radarr/Radarr"
                    "Prowlarr/Prowlarr"
                    "sabnzbd/sabnzbd"
                    "Tautulli/Tautulli"
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };

  # Environment variables for API keys
  systemd.services.glance.environment = {
    SONARR_API_KEY = "3334f2d003d148108d0084d270c8fcf9";
    RADARR_API_KEY = "9a2534c83b4f492680a95c4d045d9b61";
    PROWLARR_API_KEY = "ca2a381695a340d8923edc6b2e03ccef";
    SABNZBD_API_KEY = "ad5eaed00c6342e58958cc9540142ecd";
    UNIFI_CONSOLE_IP = "192.168.1.1";
    UNIFI_API_KEY = "DkNpJ8CbHHrd02I-3G7X2MeiP6JtfXQN";
  };

  # Open port 8000 for the dashboard
  networking.firewall.allowedTCPPorts = [ 8000 ];
}
