{ pkgs, ... }:
{
  users.users.julian = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    openssh.authorizedKeys.keys = [
    ];
  };
}
