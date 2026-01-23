{
  services.prowlarr = {
    enable = true;

    settings = {
      server = {
        port = 9696;
        bindaddress = "127.0.0.1";
        urlbase = "/prowlarr";
      };
    };
  };
}