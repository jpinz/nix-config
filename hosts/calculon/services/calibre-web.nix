{
  services.calibre-web = {
    enable = true;
    group = "services";
    listen.ip = "0.0.0.0";
    listen.port = 8083;
    openFirewall = true;
    options = {
      calibreLibrary = "/mnt/data/ebooks/calibre-web";
      enableBookUploading = true;
      enableBookConversion = true;
    };
  };
}
