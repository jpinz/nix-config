{
  services.homebox = {
    enable = true;
    settings = {
      HBOX_WEB_HOST = "0.0.0.0";
      HBOX_WEB_PORT = "7745";
      # Flip to "false" after initial setup if desired.
      HBOX_OPTIONS_ALLOW_REGISTRATION = "true";
    };
  };
}
