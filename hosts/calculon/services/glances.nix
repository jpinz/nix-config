{ pkgs, ... }:
{
  systemd.services.glances = {
    description = "Glances system monitoring web server";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.glances}/bin/glances -w -B 0.0.0.0";
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
