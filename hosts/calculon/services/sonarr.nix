{ config, lib, ... }:
{
  services.sonarr = {
    enable = true;
    group = "services";

    settings = {
      server = {
        port = 8989;
        bindaddress = "127.0.0.1";
        urlbase = "/sonarr";
      };
    };
  };

  systemd.services.sonarr-anime = {
    description = "Sonarr Anime";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      SONARR__LOG__ANALYTICSENABLED = "false";
      SONARR__SERVER__BINDADDRESS = "127.0.0.1";
      SONARR__SERVER__PORT = "8990";
      SONARR__SERVER__URLBASE = "/sonarr-anime";
      SONARR__UPDATE__AUTOMATICALLY = "false";
      SONARR__UPDATE__MECHANISM = "external";
    };
    serviceConfig = {
      Type = "simple";
      User = config.services.sonarr.user;
      Group = config.services.sonarr.group;
      ExecStart = "${lib.getExe config.services.sonarr.package} -nobrowser -data=/var/lib/sonarr-anime";
      Restart = "on-failure";
      StateDirectory = "sonarr-anime";
      StateDirectoryMode = "0750";
      UMask = "0022";

      CapabilityBoundingSet = "";
      LockPersonality = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        "~@debug"
        "~@mount"
        "@chown"
      ];
    };
  };
}
