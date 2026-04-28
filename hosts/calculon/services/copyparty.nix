{ ... }:
{
  services.copyparty = {
    enable = true;
    settings = {
      i = "127.0.0.1";
      p = [ 3923 ];
      rp-loc = "/copyparty";
    };
    volumes = {
      "/data" = {
        path = "/mnt/data";
        access = {
          r = "*";
        };
      };
    };
  };
}
