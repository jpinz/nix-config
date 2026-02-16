{
  services.lidarr = {
    enable = true;
    group = "services";

    settings = {
      server = {
        port = 8686;
        bindaddress = "127.0.0.1";
        urlbase = "/lidarr";
      };
    };
  };
}
