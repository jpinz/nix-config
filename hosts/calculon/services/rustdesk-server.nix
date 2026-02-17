{
  services.rustdesk-server = {
    enable = true;
    openFirewall = true;

    signal = {
      enable = true;
      relayHosts = [ "127.0.0.1" ];
    };

    relay = {
      enable = true;
    };
  };
}
