{ config, inputs, pkgs, ... }:
{
  imports = [
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-pc-ssd

    ./hardware-configuration.nix
    ./secrets.nix

    ../common/global
    ../common/users/julian.nix

    ../common/optional/systemd-boot.nix
    ../common/optional/vscode-server.nix

    ./services
  ];

  networking = {
    hostName = "calculon";
    hostId = "c1f22144";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  boot.extraModprobeConfig = ''
    options zfs zfs_arc_max=${toString (16 * 1024 * 1024 * 1024)}
  '';

  fileSystems."/mnt/archive" = {
    device = "/dev/disk/by-uuid/ef806f91-c45f-4986-87db-8fd6d4750c03";
    fsType = "ext4";
    options = [
      "nofail"
      "x-systemd.device-timeout=10s"
    ];
  };

  fileSystems."/mnt/nas-media" = {
    device = "192.168.1.128:/volume1/media";
    fsType = "nfs";
    options = [
      "_netdev"
      "nofail"
      "noauto"
      "rw"
      "nfsvers=4.1"
      "x-systemd.automount"
      "x-systemd.idle-timeout=10min"
      "x-systemd.mount-timeout=30s"
    ];
  };

  system.stateVersion = "23.05";

  hardware.bluetooth.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      # Pascal GPUs require the proprietary 580 legacy driver.
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };
  };
}
