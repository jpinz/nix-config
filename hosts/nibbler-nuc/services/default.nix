{ config, ... }:
{
  imports = [
    ./adguard.nix
    ./glance.nix
    ./homebox.nix
    ./tandoor.nix
  ];

  users.groups.services.members = with config.services; [

  ];

}
