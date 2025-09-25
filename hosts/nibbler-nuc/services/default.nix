{ config, ... }:
{
  imports = [
    ./adguard.nix
    ./glance.nix
    ./homebox.nix
    ./home-assistant
    ./tandoor.nix
  ];

  users.groups.services.members = with config.services; [

  ];

}
