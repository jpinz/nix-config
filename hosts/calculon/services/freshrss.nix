{ config, ... }:
{
  services.freshrss = {
    enable = true;
    baseUrl = "http://calculon.home/rss";
    defaultUser = "julian";
    passwordFile = config.sops.secrets.freshrss_password.path;
    webserver = "caddy";
    virtualHost = "http://freshrss.internal";
  };

  systemd.services.freshrss-import-subscriptions = {
    description = "Import initial FreshRSS subscriptions";
    wantedBy = [ "multi-user.target" ];
    requires = [ "freshrss-config.service" ];
    after = [ "freshrss-config.service" ];
    environment.DATA_PATH = config.services.freshrss.dataDir;

    serviceConfig = {
      Type = "oneshot";
      User = config.services.freshrss.user;
      Group = config.services.freshrss.user;
      WorkingDirectory = config.services.freshrss.package;
      ReadWritePaths = [ config.services.freshrss.dataDir ];
    };
    unitConfig.ConditionPathExists = "!${config.services.freshrss.dataDir}/.subscriptions-imported";

    script = ''
      ./cli/import-for-user.php \
        --user ${config.services.freshrss.defaultUser} \
        --filename ${config.sops.templates."freshrss-subscriptions.opml".path}
      touch ${config.services.freshrss.dataDir}/.subscriptions-imported
    '';
  };
}