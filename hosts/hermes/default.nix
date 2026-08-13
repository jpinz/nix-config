{ inputs, lib, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-gpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/julian.nix

    ../common/optional/systemd-boot.nix
    ../common/optional/vscode-server.nix

    ./services
  ];

  services.tailscale.enable = lib.mkForce false;

  networking.hostName = "hermes";

  users.users.julian = {
    extraGroups = [ "hermes" ];
  };

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  system.stateVersion = "26.05";
}