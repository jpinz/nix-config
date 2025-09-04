{ lib, ... }:
{
  services.homebox = {
    enable = true;
    settings = {
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 7745 ];
    allowedUDPPorts = [ 7745 ];
  };

}
