{ inputs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-intel
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix

    ../common/global
    ../common/users/julian.nix

    ../common/optional/systemd-boot.nix
    ../common/optional/vscode-server.nix

    ./services
  ];

  networking = {
    hostName = "nibbler-nuc";
    hostId = "a1b2c3d4";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "23.05";
}
