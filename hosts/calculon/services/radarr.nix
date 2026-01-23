{
  services.radarr = {
    enable = true;
    group = "services";

    settings = {
      server = {
        port = 7878;
        bindaddress = "127.0.0.1";
        urlbase = "/radarr";
      };
    };
  };
}