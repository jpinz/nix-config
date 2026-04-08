{
  services.shelfmark = {
    enable = true;
    openFirewall = true;
    environment = {
      FLASK_HOST = "0.0.0.0";
      FLASK_PORT = 8084;
    };
  };
}
