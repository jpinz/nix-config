{ lib, ... }:
{
  services = {
    matter-server = {
      enable = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 5580 ];
}
