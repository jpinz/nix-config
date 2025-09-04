{ config, ... }:
{
  imports = [
    ./adguard.nix
    ./homebox.nix
    ./home-assistant
  ];

  users.groups.services.members = with config.services; [

  ];

}
