{ lib, ... }:
{
  services.mealie = {
    enable = true;
    settings = {
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 9000 ];
    allowedUDPPorts = [ 9000 ];
  };

}
