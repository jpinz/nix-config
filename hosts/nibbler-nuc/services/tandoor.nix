{ lib, ... }:
{
  services.tandoor-recipes = {
    enable = true;
    port = 9000;
    address = "nibbler.local";
  };
  networking.firewall = {
    allowedTCPPorts = [ 9000 ];
    allowedUDPPorts = [ 9000 ];
  };

}
