{ config, ... }:
{
  imports = [
    ./adguard.nix
    ./homebox.nix
    ./home-assistant
    ./mealie.nix
  ];

  users.groups.services.members = with config.services; [

  ];

}
