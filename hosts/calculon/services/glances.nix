{ pkgs, ... }:
let
  configFile = pkgs.writeText "glances.conf" ''
    [outputs]
    url_prefix=/monitor/
  '';
in
{
  services.glances = {
    enable = true;
    openFirewall = false;
    extraArgs = [
      "--webserver"
      "--bind"
      "127.0.0.1"
      "--config"
      "${configFile}"
      "--disable-check-update"
    ];
  };
}