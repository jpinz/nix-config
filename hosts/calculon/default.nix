{ inputs, pkgs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/julian.nix

    ../common/optional/systemd-boot.nix
    ../common/optional/vscode-server.nix

    ./services
  ];

  networking = {
    hostName = "nixos";
    hostId = "c1f22144";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "23.05";

  hardware.bluetooth.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = true;
    };
  };
}
