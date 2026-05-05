{ ... }:
{
  services.copyparty = {
    enable = true;
    group = "services";
    settings = {
      i = "127.0.0.1";
      p = [ 3923 ];
      rp-loc = "/copyparty";
    };
    accounts = {
      julian.passwordFile = "/etc/copyparty/julian-password";
      david.passwordFile = "/etc/copyparty/david-password";
    };
    volumes = {
      "/data" = {
        path = "/mnt/data";
        access = {
          rw = [ "julian" "david" ];
        };
      };
    };
  };
}
