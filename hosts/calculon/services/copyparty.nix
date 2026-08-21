{ config, ... }:
{
  sops.secrets = {
    COPYPARTY_JULIAN_PASSWORD = {
      owner = config.services.copyparty.user;
      group = config.services.copyparty.group;
      mode = "0440";
      restartUnits = [ "copyparty.service" ];
    };
    COPYPARTY_DAVID_PASSWORD = {
      owner = config.services.copyparty.user;
      group = config.services.copyparty.group;
      mode = "0440";
      restartUnits = [ "copyparty.service" ];
    };
  };

  services.copyparty = {
    enable = true;
    group = "services";
    settings = {
      i = "127.0.0.1";
      p = [ 3923 ];
      rp-loc = "/copyparty";
    };
    accounts = {
      julian.passwordFile = config.sops.secrets.COPYPARTY_JULIAN_PASSWORD.path;
      david.passwordFile = config.sops.secrets.COPYPARTY_DAVID_PASSWORD.path;
    };
    volumes = {
      "/data" = {
        path = "/mnt/data";
        access = {
          rw = [
            "julian"
            "david"
          ];
        };
      };
    };
  };
}
