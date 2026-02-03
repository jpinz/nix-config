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
                      title = "Radarr";
                      url = "http://calculon.home/radarr";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/radarr.svg";
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
                      title = "SABnzbd";
                      url = "http://calculon.home/sabnzbd";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/sabnzbd.svg";
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
                      title = "Calibre-Web";
                      url = "http://calculon.home/calibre";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/calibre-web.svg";
                    }
                    {
                      title = "Overseerr";
                      url = "http://calculon.home:5055";
                      icon = "https://cdn.jsdelivr.net/gh/selfhst/icons/svg/overseerr.svg";
                    }
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
                # System Status (Glances) — shown above Unifi
                {
                  type = "custom-api";
                  cache = "30s";
                  title = "Server Stats";
                  options = {
                    glances-url = "http://\${GLANCES_URL}:61208";
                    server-name = "Calculon";
                    show-temperature = "true";
                    show-disk-bar = "true";
                    show-network = "false";
                    network-interface = "eth0";
                  };
                  template = ''
                    {{ $glancesUrl := .Options.StringOr "glances-url" "http://127.0.0.1:61208" }}
                    {{ $baseUrl := concat $glancesUrl "/api/4" }}
                    {{ $serverName := .Options.StringOr "server-name" "Server" }}
                    {{ $showTemp := eq (.Options.StringOr "show-temperature" "true") "true" }}
                    {{ $showDiskBar := eq (.Options.StringOr "show-disk-bar" "true") "true" }}
                    {{ $showNetwork := eq (.Options.StringOr "show-network" "false") "true" }}
                    {{ $ifName := .Options.StringOr "network-interface" "eth0" }}

                    {{ $cpu := newRequest (concat $baseUrl "/cpu") | getResponse }}
                    {{ $mem := newRequest (concat $baseUrl "/mem") | getResponse }}
                    {{ $fs := newRequest (concat $baseUrl "/fs") | getResponse }}
                    {{ $uptime := newRequest (concat $baseUrl "/uptime") | getResponse }}
                    {{ $swap := newRequest (concat $baseUrl "/memswap") | getResponse }}
                    {{ $net := newRequest (concat $baseUrl "/network") | getResponse }}
                    {{ $sensors := newRequest (concat $baseUrl "/sensors") | getResponse }}

                    {{ $isOnline := and (eq $cpu.Response.StatusCode 200) (eq $mem.Response.StatusCode 200) }}

                    {{ if $isOnline }}
                      {{ $cpuPercent := $cpu.JSON.Float "total" | toInt }}
                      {{ $memPercent := $mem.JSON.Float "percent" | toInt }}
                      {{ $memUsedGB := div ($mem.JSON.Float "used") 1073741824 }}
                      {{ $memTotalGB := div ($mem.JSON.Float "total") 1073741824 }}

                      {{ $swapUsedMB := 0 }}
                      {{ $swapTotalMB := 0 }}
                      {{ if eq $swap.Response.StatusCode 200 }}
                        {{ $swapUsedMB = div ($swap.JSON.Float "used") 1048576 | toInt }}
                        {{ $swapTotalMB = div ($swap.JSON.Float "total") 1048576 | toInt }}
                      {{ end }}

                      {{ $uptimeStr := "" }}
                      {{ if eq $uptime.Response.StatusCode 200 }}
                        {{ $uptimeStr = $uptime.JSON.String "" }}
                      {{ end }}

                      {{ $temperature := 0 }}
                      {{ if and $showTemp (eq $sensors.Response.StatusCode 200) }}
                        {{ range $sensors.JSON.Array "" }}
                          {{ $type := .String "type" }}
                          {{ $unit := .String "unit" }}
                          {{ $valueInt := .Float "value" | toInt }}
                          {{ if and (eq $type "temperature_core") (eq $unit "C") (gt $valueInt 0) }}
                            {{ if gt $valueInt 200 }}
                              {{ $temperature = div $valueInt 1000 }}
                            {{ else }}
                              {{ $temperature = $valueInt }}
                            {{ end }}
                          {{ end }}
                        {{ end }}
                      {{ end }}

                      {{ $netDownMBs := 0.0 }}
                      {{ $netUpMBs := 0.0 }}
                      {{ if and $showNetwork (eq $net.Response.StatusCode 200) }}
                        {{ range $net.JSON.Array "" }}
                          {{ if eq (.String "interface_name") $ifName }}
                            {{ $netDownMBs = div (.Float "bytes_recv_rate_per_sec") 1048576 }}
                            {{ $netUpMBs = div (.Float "bytes_sent_rate_per_sec") 1048576 }}
                          {{ end }}
                        {{ end }}
                      {{ end }}

                      <style>
                        .server-container { padding: 0.5rem; }
                        .server-header {
                          display: flex;
                          justify-content: space-between;
                          align-items: center;
                          margin-bottom: 1rem;
                          padding-bottom: 0.75rem;
                          border-bottom: 1px solid var(--color-separator);
                        }
                        .server-name-link {
                          color: var(--color-text-subdue);
                          text-decoration: none;
                          transition: color 0.2s;
                        }
                        .server-name-link:hover { color: var(--color-primary); }
                        .services-section {
                          margin-bottom: 1rem;
                          display: flex;
                          align-items: center;
                          gap: 0.5rem;
                        }
                        .status-indicator {
                          display: flex;
                          align-items: center;
                          justify-content: center;
                          width: 1.5rem;
                          height: 1.5rem;
                          border-radius: 50%;
                          background: #22c55e;
                          flex-shrink: 0;
                        }
                        .status-indicator.offline { background: #ef4444; }
                        .status-icon { width: 1rem; height: 1rem; color: white; }
                        .services-info { flex: 1; }
                        .uptime-temp-row {
                          display: flex;
                          align-items: center;
                          gap: 0.5rem;
                          justify-content: space-between;
                        }
                        .temp-display {
                          padding: 0.25rem 0.6rem;
                          border-radius: 4px;
                          white-space: nowrap;
                        }
                        .temp-low { background: rgba(34, 197, 94, 0.15); color: #22c55e; }
                        .temp-medium { background: rgba(234, 179, 8, 0.15); color: #eab308; }
                        .temp-high { background: rgba(239, 68, 68, 0.15); color: #ef4444; }
                        .metrics-grid {
                          display: grid;
                          grid-template-columns: repeat(3, 1fr);
                          gap: 0.75rem;
                          margin-bottom: 1rem;
                        }
                        .metric-card {
                          background: var(--color-widget-background);
                          border: 1px solid var(--color-separator);
                          border-radius: var(--border-radius-primary);
                          padding: 0.75rem;
                          text-align: center;
                        }
                        .metric-bar {
                          width: 100%;
                          height: 4px;
                          background: var(--color-separator);
                          border-radius: 2px;
                          overflow: hidden;
                          margin-top: 0.5rem;
                          position: relative;
                        }
                        .metric-bar-fill {
                          height: 100%;
                          position: absolute;
                          left: 0;
                          top: 0;
                          transition: width 0.3s ease;
                        }
                        .bar-low { background: linear-gradient(90deg, #22c55e 0%, #16a34a 100%); }
                        .bar-medium { background: linear-gradient(90deg, #eab308 0%, #ca8a04 100%); }
                        .bar-high { background: linear-gradient(90deg, #ef4444 0%, #dc2626 100%); }
                        .memory-section {
                          background: var(--color-widget-background);
                          border: 1px solid var(--color-separator);
                          border-radius: var(--border-radius-primary);
                          padding: 0.75rem;
                          margin-bottom: 1rem;
                        }
                        .memory-row {
                          display: flex;
                          justify-content: space-between;
                          align-items: center;
                          padding: 0.4rem 0;
                        }
                        .disks-section {
                          background: var(--color-widget-background);
                          border: 1px solid var(--color-separator);
                          border-radius: var(--border-radius-primary);
                          padding: 0.75rem;
                          margin-bottom: 1rem;
                        }
                        .disk-item { margin-bottom: 0.75rem; }
                        .disk-item:last-child { margin-bottom: 0; }
                        .disk-header {
                          display: flex;
                          justify-content: space-between;
                          align-items: center;
                          margin-bottom: 0.35rem;
                        }
                        .network-section {
                          display: grid;
                          grid-template-columns: 1fr 1fr;
                          gap: 0.75rem;
                        }
                        .network-card {
                          background: var(--color-widget-background);
                          border: 1px solid var(--color-separator);
                          border-radius: var(--border-radius-primary);
                          padding: 0.75rem;
                          text-align: center;
                        }
                        .icon-server { width: 1.5rem; height: 1.5rem; }
                      </style>

                      <div class="server-container">
                        <div class="server-header">
                          {{ if ne $glancesUrl "" }}
                          <a href="{{ $glancesUrl }}" target="_blank" class="server-name-link">
                            <span class="size-h6 color-text-subdue" style="font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">{{ $serverName }}</span>
                          </a>
                          {{ else }}
                          <span class="size-h6 color-text-subdue" style="font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">{{ $serverName }}</span>
                          {{ end }}
                          <svg class="icon-server" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M4,1H20A1,1 0 0,1 21,2V6A1,1 0 0,1 20,7H4A1,1 0 0,1 3,6V2A1,1 0 0,1 4,1M4,9H20A1,1 0 0,1 21,10V14A1,1 0 0,1 20,15H4A1,1 0 0,1 3,14V10A1,1 0 0,1 4,9M4,17H20A1,1 0 0,1 21,18V22A1,1 0 0,1 20,23H4A1,1 0 0,1 3,22V18A1,1 0 0,1 4,17M5,4V5H7V4H5M5,12V13H7V12H5M5,20V21H7V20H5M9,4V5H11V4H9M9,12V13H11V12H9M9,20V21H11V20H9Z"/>
                          </svg>
                        </div>

                        <div class="services-section">
                          <div class="status-indicator">
                            <svg class="status-icon" viewBox="0 0 24 24" fill="currentColor">
                              <path d="M21,7L9,19L3.5,13.5L4.91,12.09L9,16.17L19.59,5.59L21,7Z"/>
                            </svg>
                          </div>
                          <div class="services-info">
                            <div class="size-h5" style="margin-bottom: 0.15rem;">Services</div>
                            <div class="uptime-temp-row">
                              {{ if ne $uptimeStr "" }}
                              <span class="size-h6 color-text-subdue">{{ $uptimeStr }} uptime</span>
                              {{ end }}
                              {{ if and $showTemp (gt $temperature 0) }}
                              {{ $tempF := add (div (mul $temperature 9) 5) 32 }}
                              <span class="size-h6 temp-display {{ if lt $tempF 149 }}temp-low{{ else if lt $tempF 176 }}temp-medium{{ else }}temp-high{{ end }}">{{ $tempF }}°F</span>
                              {{ end }}
                            </div>
                          </div>
                        </div>

                        <div class="metrics-grid">
                          <div class="metric-card">
                            <div class="size-h6 color-text-subdue" style="text-transform: uppercase; margin-bottom: 0.5rem;">CPU</div>
                            <div class="size-h2" style="font-weight: 700; margin-bottom: 0.25rem;">{{ $cpuPercent }}%</div>
                            <div class="metric-bar">
                              <div class="metric-bar-fill {{ if lt $cpuPercent 60 }}bar-low{{ else if lt $cpuPercent 80 }}bar-medium{{ else }}bar-high{{ end }}" style="width: {{ $cpuPercent }}%"></div>
                            </div>
                          </div>

                          <div class="metric-card">
                            <div class="size-h6 color-text-subdue" style="text-transform: uppercase; margin-bottom: 0.5rem;">RAM</div>
                            <div class="size-h2" style="font-weight: 700; margin-bottom: 0.25rem;">{{ $memPercent }}%</div>
                            <div class="metric-bar">
                              <div class="metric-bar-fill {{ if lt $memPercent 60 }}bar-low{{ else if lt $memPercent 80 }}bar-medium{{ else }}bar-high{{ end }}" style="width: {{ $memPercent }}%"></div>
                            </div>
                          </div>

                          <div class="metric-card">
                            <div class="size-h6 color-text-subdue" style="text-transform: uppercase; margin-bottom: 0.5rem;">DISK</div>
                            <div class="size-h2" style="font-weight: 700; margin-bottom: 0.25rem;">
                              {{ $totalDiskPercent := 0 }}
                              {{ $diskCount := 0 }}
                              {{ range $fs.JSON.Array "" }}
                                {{ $totalDiskPercent = add $totalDiskPercent (.Float "percent" | toInt) }}
                                {{ $diskCount = add $diskCount 1 }}
                              {{ end }}
                              {{ if gt $diskCount 0 }}{{ div $totalDiskPercent $diskCount }}%{{ else }}0%{{ end }}
                            </div>
                            {{ if $showDiskBar }}
                            <div class="metric-bar">
                              {{ $avgPercent := 0 }}
                              {{ $diskCount := 0 }}
                              {{ range $fs.JSON.Array "" }}
                                {{ $avgPercent = add $avgPercent (.Float "percent" | toInt) }}
                                {{ $diskCount = add $diskCount 1 }}
                              {{ end }}
                              {{ if gt $diskCount 0 }}{{ $avgPercent = div $avgPercent $diskCount }}{{ end }}
                              <div class="metric-bar-fill {{ if lt $avgPercent 60 }}bar-low{{ else if lt $avgPercent 80 }}bar-medium{{ else }}bar-high{{ end }}" style="width: {{ $avgPercent }}%"></div>
                            </div>
                            {{ end }}
                          </div>
                        </div>

                        <div class="memory-section">
                          <div class="memory-row">
                            <span class="size-h6 color-text-subdue" style="text-transform: uppercase;">RAM</span>
                            <span class="size-h6" style="font-weight: 500;">{{ $memUsedGB | printf "%.1f" }} GB / {{ $memTotalGB | printf "%.1f" }} GB</span>
                          </div>
                          {{ if gt $swapTotalMB 0 }}
                          <div class="memory-row">
                            <span class="size-h6 color-text-subdue" style="text-transform: uppercase;">SWAP</span>
                            <span class="size-h6" style="font-weight: 500;">{{ $swapUsedMB }} MB / {{ $swapTotalMB }} MB</span>
                          </div>
                          {{ end }}
                        </div>

                        {{ if eq $fs.Response.StatusCode 200 }}
                        <div class="disks-section">
                          {{ $device1 := "" }}
                          {{ $device2 := "" }}
                          {{ $device3 := "" }}
                          {{ $device4 := "" }}
                          {{ $device5 := "" }}
                          {{ range $fs.JSON.Array "" }}
                            {{ $deviceName := .String "device_name" }}
                            {{ $isNewDevice := true }}
                            {{ if or (eq $deviceName $device1) (eq $deviceName $device2) (eq $deviceName $device3) (eq $deviceName $device4) (eq $deviceName $device5) }}
                              {{ $isNewDevice = false }}
                            {{ end }}
                            {{ if and $isNewDevice (ne $deviceName "") }}
                              {{ if eq $device1 "" }}
                                {{ $device1 = $deviceName }}
                              {{ else if eq $device2 "" }}
                                {{ $device2 = $deviceName }}
                              {{ else if eq $device3 "" }}
                                {{ $device3 = $deviceName }}
                              {{ else if eq $device4 "" }}
                                {{ $device4 = $deviceName }}
                              {{ else if eq $device5 "" }}
                                {{ $device5 = $deviceName }}
                              {{ end }}
                              {{ $diskPercent := .Float "percent" | toInt }}
                              {{ $diskUsedGB := div (.Float "used") 1073741824 }}
                              {{ $diskTotalGB := div (.Float "size") 1073741824 }}
                              {{ $diskTotalGBInt := $diskTotalGB | toInt }}
                              <div class="disk-item">
                                <div class="disk-header">
                                  <span class="size-h6 color-text-subdue" style="text-transform: uppercase;">{{ $deviceName }}</span>
                                  {{ if gt $diskTotalGBInt 1000 }}
                                  <span class="size-h6" style="font-weight: 500;">{{ div $diskUsedGB 1024 | printf "%.1f" }} TB / {{ div $diskTotalGB 1024 | printf "%.1f" }} TB</span>
                                  {{ else }}
                                  <span class="size-h6" style="font-weight: 500;">{{ $diskUsedGB | printf "%.1f" }} GB / {{ $diskTotalGB | printf "%.1f" }} GB</span>
                                  {{ end }}
                                </div>
                                {{ if $showDiskBar }}
                                <div class="metric-bar">
                                  <div class="metric-bar-fill {{ if lt $diskPercent 60 }}bar-low{{ else if lt $diskPercent 80 }}bar-medium{{ else }}bar-high{{ end }}" style="width: {{ $diskPercent }}%"></div>
                                </div>
                                {{ end }}
                              </div>
                            {{ end }}
                          {{ end }}
                        </div>
                        {{ end }}

                        {{ if $showNetwork }}
                        <div class="network-section">
                          <div class="network-card">
                            <div class="size-h6 color-text-subdue" style="text-transform: uppercase; margin-bottom: 0.5rem;">↓ Download</div>
                            <div class="size-h4 color-highlight" style="font-weight: 700;">{{ $netDownMBs | printf "%.2f" }} MB/s</div>
                          </div>
                          <div class="network-card">
                            <div class="size-h6 color-text-subdue" style="text-transform: uppercase; margin-bottom: 0.5rem;">↑ Upload</div>
                            <div class="size-h4 color-highlight" style="font-weight: 700;">{{ $netUpMBs | printf "%.2f" }} MB/s</div>
                          </div>
                        </div>
                        {{ end }}
                      </div>
                    {{ else }}
                      <div class="server-container">
                        <div class="server-header">
                          <span class="size-h6 color-text-subdue" style="font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px;">{{ $serverName }}</span>
                          <svg class="icon-server" viewBox="0 0 24 24" fill="currentColor">
                            <path d="M4,1H20A1,1 0 0,1 21,2V6A1,1 0 0,1 20,7H4A1,1 0 0,1 3,6V2A1,1 0 0,1 4,1M4,9H20A1,1 0 0,1 21,10V14A1,1 0 0,1 20,15H4A1,1 0 0,1 3,14V10A1,1 0 0,1 4,9M4,17H20A1,1 0 0,1 21,18V22A1,1 0 0,1 20,23H4A1,1 0 0,1 3,22V18A1,1 0 0,1 4,17M5,4V5H7V4H5M5,12V13H7V12H5M5,20V21H7V20H5M9,4V5H11V4H9M9,12V13H11V12H9M9,20V21H11V20H9Z"/>
                          </svg>
                        </div>
                        <div class="services-section">
                          <div class="status-indicator offline">
                            <svg class="status-icon" viewBox="0 0 24 24" fill="currentColor">
                              <path d="M19,6.41L17.59,5L12,10.59L6.41,5L5,6.41L10.59,12L5,17.59L6.41,19L12,13.41L17.59,19L19,17.59L13.41,12L19,6.41Z"/>
                            </svg>
                          </div>
                          <div class="services-info">
                            <div class="size-h5" style="margin-bottom: 0.15rem;">Services</div>
                            <div class="size-h6 color-negative">Offline</div>
                          </div>
                        </div>
                        <p class="color-negative" style="text-align: center; margin-top: 1rem;">Failed to fetch server data</p>
                      </div>
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
                    "glanceapp/glance"
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
    GLANCES_URL = "127.0.0.1";
  };

  # Open port 8000 for the dashboard
  networking.firewall.allowedTCPPorts = [ 8000 ];
}
