{
  services.calibre-web = {
    enable = true;
    group = "services";
    listen.ip = "0.0.0.0";
    listen.port = 8083;
    openFirewall = true;
    options = {
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };
}
