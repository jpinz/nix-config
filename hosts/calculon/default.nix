{ inputs, pkgs, ... }:
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
    hostName = "calculon";
    hostId = "a1b2c3d4";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "23.05";

  hardware.bluetooth.enable = true;

  # Intel Quick Sync Video (QSV) for hardware transcoding
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD (Broadwell+)
      intel-compute-runtime # OpenCL support
    ];
  };
}
