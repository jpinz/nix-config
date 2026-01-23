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
}