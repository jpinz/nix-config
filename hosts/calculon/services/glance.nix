{ config, ... }:
{
  services.glance = {
    enable = true;
    environmentFile = config.sops.secrets.glance_env.path;
    settings = {
      server = {
        host = "127.0.0.1";
        port = 8000;
        proxied = true;
        base-url = "/dashboard";
      };
      branding = {
        logo-text = "Calculon";
        hide-footer = true;
      };
      pages = [
        {
          name = "Home";
          head-widgets = [
            {
              type = "search";
              # Default to Bing, add bangs for Kagi and Google
              search-engine = "bing";
              hide-header = true;
              placeholder = "Search (use !k for Kagi, !g for Google)";
              bangs = [
                {
                  title = "Kagi";
                  shortcut = "!k";
                  url = "https://kagi.com/search?q={QUERY}";
                }
                {
                  title = "Google";
                  shortcut = "!g";
                  url = "https://www.google.com/search?q={QUERY}";
                }
              ];
            }
          ];
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
                  first-day-of-week = "sunday";
                }
                {
                  type = "bookmarks";
                  groups = [
                    {
                      links = [
                        {
                          title = "Home Assistant";
                          url = "http://homeassistant.local:8123/";
                          icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/home-assistant.svg";
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
                      type = "rss";
                      title = "Wired";
                      style = "detailed-list";
                      limit = 15;
                      collapse-after = 5;
                      feeds = [
                        {
                          url = "https://www.wired.com/feed/rss";
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
                    {
                      type = "reddit";
                      title = "/r/magictcg";
                      subreddit = "magictcg";
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
                  url = "http://calculon.home/sabnzbd/api?output=json&apikey=\${SABNZBD_API_KEY}&mode=queue";
                  title-url = "http://calculon.home/sabnzbd";
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
                  title-url = "http://calculon.home/prowlarr";
                  options = {
                    url = "http://calculon.home/prowlarr";
                    base-url = "http://calculon.home/prowlarr";
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
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/plex.svg";
                    }
                    {
                      title = "Homebox";
                      url = "http://calculon.home:7745";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/homebox.svg";
                    }
                    {
                      title = "Sonarr";
                      url = "http://calculon.home/sonarr";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sonarr.svg";
                    }
                    {
                      title = "Sonarr Anime";
                      url = "http://calculon.home/sonarr-anime";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sonarr.svg";
                    }
                    {
                      title = "Radarr";
                      url = "http://calculon.home/radarr";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/radarr.svg";
                    }
                    {
                      title = "Lidarr";
                      url = "http://calculon.home/lidarr";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/lidarr.svg";
                    }
                    {
                      title = "Bazarr";
                      url = "http://calculon.home:6767";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/bazarr.svg";
                    }
                    {
                      title = "Prowlarr";
                      url = "http://calculon.home/prowlarr";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/prowlarr.svg";
                    }
                    {
                      title = "Profilarr";
                      url = "http://calculon.home:6868";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/profilarr.svg";
                    }
                    {
                      title = "SABnzbd";
                      url = "http://calculon.home/sabnzbd";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg";
                    }
                    {
                      title = "Glances";
                      url = "http://calculon.home/monitor/";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/glances.svg";
                    }
                    {
                      title = "Tautulli";
                      url = "http://calculon.home:8181";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/tautulli.svg";
                    }
                    {
                      title = "Audiobookshelf";
                      url = "http://calculon.home/audiobookshelf";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/audiobookshelf.svg";
                    }
                    {
                      title = "Navidrome";
                      url = "http://calculon.home/navidrome";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/navidrome.svg";
                    }
                    {
                      title = "Shelfmark";
                      url = "http://calculon.home:8084";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/shelfmark.svg";
                    }
                    {
                      title = "Calibre-Web";
                      url = "http://calculon.home/calibre";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/calibre-web.svg";
                    }
                    {
                      title = "FreshRSS";
                      url = "http://calculon.home/rss";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/freshrss.svg";
                    }
                    # {
                    #   title = "Grafana";
                    #   url = "http://calculon.home/grafana";
                    #   icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/grafana.svg";
                    # }
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "group";
                  style = "tabs-static";
                  widgets = [
                    # Sonarr Upcoming Widget
                    {
                      type = "custom-api";
                      title = "Upcoming TV";
                      title-url = "http://calculon.home/sonarr";
                      cache = "15m";
                      options = {
                        base-url = "http://calculon.home/sonarr";
                        api-key = "\${SONARR_API_KEY}";
                        collapse-after = 5;
                      };
                      template = ''
                        {{ $baseUrl := .Options.StringOr "base-url" "" }}
                        {{ $apiKey := .Options.StringOr "api-key" "" }}
                        {{ $collapseAfter := .Options.IntOr "collapse-after" 5 }}

                        {{ $calendarUrl := printf "%s/api/v3/calendar?start=%s&end=%s&includeSeries=true" $baseUrl (now | formatTime "2006-01-02") ((now.Add (duration "168h")) | formatTime "2006-01-02") }}
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
                                    <span class="color-highlight text-truncate">{{ .String "series.title" }}</span>
                                    <span class="color-primary shrink-0" style="margin-left: 0.5rem;">{{ .String "airDateUtc" | parseTime "2006-01-02T15:04:05Z" | formatTime "Jan 2" }}</span>
                                  </div>
                                  <div class="color-subdue text-truncate size-h6">S{{ .Int "seasonNumber" }} E{{ .Int "episodeNumber" }}</div>
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
                      title-url = "http://calculon.home/radarr";
                      cache = "15m";
                      options = {
                        base-url = "http://calculon.home/radarr";
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
                  ];
                }
                {
                  type = "group";
                  style = "tabs-static";
                  widgets = [
                    # System Status (Glances)
                    {
                      type = "custom-api";
                      title = "Calculon";
                      title-url = "http://calculon.home/monitor/";
                      cache = "10s";
                      url = "http://127.0.0.1:61208/monitor/api/4/cpu";
                      subrequests = {
                        percpu.url = "http://127.0.0.1:61208/monitor/api/4/percpu";
                        sensors.url = "http://127.0.0.1:61208/monitor/api/4/sensors";
                        mem.url = "http://127.0.0.1:61208/monitor/api/4/mem";
                        memswap.url = "http://127.0.0.1:61208/monitor/api/4/memswap";
                        fs.url = "http://127.0.0.1:61208/monitor/api/4/fs";
                        folders.url = "http://127.0.0.1:61208/monitor/api/4/folders";
                        load.url = "http://127.0.0.1:61208/monitor/api/4/load";
                        uptime.url = "http://127.0.0.1:61208/monitor/api/4/uptime";
                      };
                      template = ''
                        <style>
                          .calculon-stats {
                            display: grid;
                            gap: 1.5rem;
                          }
                          .calculon-stats__meta,
                          .calculon-stats__heading,
                          .calculon-stats__row-label {
                            display: flex;
                            align-items: baseline;
                            justify-content: space-between;
                            gap: 0.8rem;
                          }
                          .calculon-stats__meta {
                            color: var(--color-text-subdue);
                            font-size: var(--font-size-tiny);
                          }
                          .calculon-stats__section {
                            display: grid;
                            gap: 0.8rem;
                            padding-top: 1.2rem;
                            border-top: 1px solid var(--color-widget-content-border);
                          }
                          .calculon-stats__section:first-of-type {
                            padding-top: 0;
                            border-top: 0;
                          }
                          .calculon-stats__heading {
                            font-size: var(--font-size-h6);
                            text-transform: uppercase;
                          }
                          .calculon-stats__cores {
                            display: grid;
                            grid-template-columns: repeat(4, minmax(0, 1fr));
                            gap: 0.6rem;
                          }
                          .calculon-stats__core {
                            min-width: 0;
                            padding: 0.55rem;
                            border: 1px solid var(--color-widget-content-border);
                            border-radius: var(--border-radius);
                          }
                          .calculon-stats__core-label,
                          .calculon-stats__row-label {
                            font-size: var(--font-size-tiny);
                          }
                          .calculon-stats__core-label {
                            display: flex;
                            justify-content: space-between;
                            gap: 0.3rem;
                          }
                          .calculon-stats__rows {
                            display: grid;
                            gap: 0.75rem;
                          }
                          .calculon-stats__meter {
                            width: 100%;
                            height: 0.45rem;
                            margin-top: 0.35rem;
                            overflow: hidden;
                            background: var(--color-widget-content-border);
                            border-radius: var(--border-radius);
                          }
                          .calculon-stats__meter > span {
                            display: block;
                            height: 100%;
                            min-width: 1px;
                            background: currentColor;
                            border-radius: inherit;
                          }
                          .calculon-stats__folder-name {
                            min-width: 0;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            text-transform: capitalize;
                            white-space: nowrap;
                          }
                        </style>

                        {{ $percpu := .Subrequest "percpu" }}
                        {{ $sensors := .Subrequest "sensors" }}
                        {{ $mem := .Subrequest "mem" }}
                        {{ $swap := .Subrequest "memswap" }}
                        {{ $fs := .Subrequest "fs" }}
                        {{ $folders := .Subrequest "folders" }}
                        {{ $load := .Subrequest "load" }}
                        {{ $uptime := .Subrequest "uptime" }}

                        {{ if eq .Response.StatusCode 200 }}
                          <div class="calculon-stats">
                            <div class="calculon-stats__meta">
                              <span>{{ $uptime.JSON.String "" }} uptime</span>
                              <span>load {{ printf "%.2f" ($load.JSON.Float "min5") }}</span>
                            </div>

                            <section class="calculon-stats__section">
                              <div class="calculon-stats__heading">
                                <span>CPU</span>
                                <span class="color-highlight">
                                  {{ printf "%.0f" (.JSON.Float "total") }}%
                                  {{ range $sensors.JSON.Array "" }}
                                    {{ if eq (.String "label") "Tctl" }} · {{ printf "%.0f" (.Float "value") }}°C{{ end }}
                                  {{ end }}
                                </span>
                              </div>
                              <div class="calculon-stats__cores">
                                {{ range $percpu.JSON.Array "" }}
                                  {{ $coreUsage := .Float "total" }}
                                  <div class="calculon-stats__core">
                                    <div class="calculon-stats__core-label">
                                      <span>CPU{{ .Int "cpu_number" }}</span>
                                      <span class="color-highlight">{{ printf "%.0f" $coreUsage }}%</span>
                                    </div>
                                    <div class="calculon-stats__meter {{ if ge $coreUsage 85.0 }}color-negative{{ else if ge $coreUsage 65.0 }}color-primary{{ else }}color-positive{{ end }}">
                                      <span style="width: {{ printf "%.1f" $coreUsage }}%"></span>
                                    </div>
                                  </div>
                                {{ end }}
                              </div>
                            </section>

                            {{ $memTotal := $mem.JSON.Float "total" }}
                            {{ $memUsed := $mem.JSON.Float "used" }}
                            {{ $memUsedPercent := $mem.JSON.Float "percent" }}
                            {{ $memAvailable := $mem.JSON.Float "available" }}
                            {{ $memAvailablePercent := mul (div $memAvailable $memTotal) 100.0 }}
                            {{ $memCached := $mem.JSON.Float "cached" }}
                            {{ $memCachedPercent := mul (div $memCached $memTotal) 100.0 }}
                            {{ $memFree := $mem.JSON.Float "free" }}
                            {{ $memFreePercent := mul (div $memFree $memTotal) 100.0 }}
                            {{ $swapTotal := $swap.JSON.Float "total" }}
                            {{ $swapUsed := $swap.JSON.Float "used" }}
                            {{ $swapPercent := $swap.JSON.Float "percent" }}
                            <section class="calculon-stats__section">
                              <div class="calculon-stats__heading">
                                <span>Memory</span>
                                <span class="color-highlight">{{ printf "%.1f" (div $memUsed 1073741824.0) }} / {{ printf "%.1f" (div $memTotal 1073741824.0) }} GiB</span>
                              </div>
                              <div class="calculon-stats__rows">
                                <div>
                                  <div class="calculon-stats__row-label"><span>Used</span><span>{{ printf "%.1f" $memUsedPercent }}%</span></div>
                                  <div class="calculon-stats__meter {{ if ge $memUsedPercent 85.0 }}color-negative{{ else }}color-primary{{ end }}"><span style="width: {{ printf "%.1f" $memUsedPercent }}%"></span></div>
                                </div>
                                <div>
                                  <div class="calculon-stats__row-label"><span>Available</span><span>{{ printf "%.1f" (div $memAvailable 1073741824.0) }} GiB</span></div>
                                  <div class="calculon-stats__meter color-positive"><span style="width: {{ printf "%.1f" $memAvailablePercent }}%"></span></div>
                                </div>
                                <div>
                                  <div class="calculon-stats__row-label"><span>Cache (reclaimable)</span><span>{{ printf "%.1f" (div $memCached 1073741824.0) }} GiB</span></div>
                                  <div class="calculon-stats__meter color-highlight"><span style="width: {{ printf "%.1f" $memCachedPercent }}%"></span></div>
                                </div>
                                <div>
                                  <div class="calculon-stats__row-label"><span>Free</span><span>{{ printf "%.1f" (div $memFree 1073741824.0) }} GiB</span></div>
                                  <div class="calculon-stats__meter color-subdue"><span style="width: {{ printf "%.1f" $memFreePercent }}%"></span></div>
                                </div>
                                <div>
                                  <div class="calculon-stats__row-label"><span>Swap</span><span>{{ printf "%.1f" (div $swapUsed 1073741824.0) }} / {{ printf "%.1f" (div $swapTotal 1073741824.0) }} GiB</span></div>
                                  <div class="calculon-stats__meter {{ if ge $swapPercent 50.0 }}color-negative{{ else }}color-subdue{{ end }}"><span style="width: {{ printf "%.1f" $swapPercent }}%"></span></div>
                                </div>
                              </div>
                            </section>

                            <section class="calculon-stats__section">
                              <div class="calculon-stats__heading"><span>Filesystems</span></div>
                              <div class="calculon-stats__rows">
                                {{ range $fs.JSON.Array "" }}
                                  {{ if or (eq (.String "mnt_point") "/") (eq (.String "mnt_point") "/mnt/data") }}
                                    {{ $diskPercent := .Float "percent" }}
                                    {{ $diskUsed := .Float "used" }}
                                    {{ $diskSize := .Float "size" }}
                                    <div>
                                      <div class="calculon-stats__row-label">
                                        <span>{{ if eq (.String "mnt_point") "/" }}System{{ else }}Data · ZFS{{ end }}</span>
                                        <span>
                                          {{ if ge $diskSize 1099511627776.0 }}
                                            {{ printf "%.1f" (div $diskUsed 1099511627776.0) }} / {{ printf "%.1f" (div $diskSize 1099511627776.0) }} TiB
                                          {{ else }}
                                            {{ printf "%.1f" (div $diskUsed 1073741824.0) }} / {{ printf "%.1f" (div $diskSize 1073741824.0) }} GiB
                                          {{ end }}
                                        </span>
                                      </div>
                                      <div class="calculon-stats__meter {{ if ge $diskPercent 85.0 }}color-negative{{ else if ge $diskPercent 70.0 }}color-primary{{ else }}color-positive{{ end }}"><span style="width: {{ printf "%.1f" $diskPercent }}%"></span></div>
                                    </div>
                                  {{ end }}
                                {{ end }}
                              </div>
                            </section>

                            {{ $dataSize := $fs.JSON.Float "#(mnt_point==\"/mnt/data\").size" }}
                            {{ $folderList := $folders.JSON.Array "" }}
                            <section class="calculon-stats__section">
                              <div class="calculon-stats__heading"><span>Media folders</span><span class="color-subdue">30m scan</span></div>
                              {{ if gt (len $folderList) 0 }}
                                <div class="calculon-stats__rows">
                                  {{ range $folderList }}
                                    {{ $folderSize := .Float "size" }}
                                    {{ $folderPercent := mul (div $folderSize $dataSize) 100.0 }}
                                    <div>
                                      <div class="calculon-stats__row-label">
                                        <span class="calculon-stats__folder-name">{{ trimPrefix "/mnt/data/" (.String "path") }}</span>
                                        {{ if eq (.Int "errno") 0 }}
                                          <span>
                                            {{ if ge $folderSize 1099511627776.0 }}
                                              {{ printf "%.2f" (div $folderSize 1099511627776.0) }} TiB
                                            {{ else }}
                                              {{ printf "%.1f" (div $folderSize 1073741824.0) }} GiB
                                            {{ end }}
                                          </span>
                                        {{ else }}
                                          <span class="color-negative">Unavailable</span>
                                        {{ end }}
                                      </div>
                                      {{ if eq (.Int "errno") 0 }}
                                        <div class="calculon-stats__meter color-primary"><span style="width: {{ printf "%.2f" $folderPercent }}%"></span></div>
                                      {{ end }}
                                    </div>
                                  {{ end }}
                                </div>
                              {{ else }}
                                <p class="color-subdue size-h6">Initial folder scan pending</p>
                              {{ end }}
                            </section>
                          </div>
                        {{ else }}
                          <p class="color-negative">Glances is unavailable</p>
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
                  ];
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
                    "glanceapp/glance"
                    "Sonarr/Sonarr"
                    "Radarr/Radarr"
                    "Lidarr/Lidarr"
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

  # Open port 8000 for the dashboard
  networking.firewall.allowedTCPPorts = [ 8000 ];
}
