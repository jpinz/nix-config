{
  disko.devices = {
    disk = {
      ssd = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      hdd = {
        type = "disk";
        device = "/dev/sdb";
        content = {
        type = "gpt";
        partitions = {
            zfs = {
            size = "100%";
            content = {
                type = "zfs";
                pool = "tank";
            };
            };
        };
      };
  };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          mountpoint = "none";
          atime = "off";
          compression = "zstd";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
          };
          nix = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/nix";
          };
          home = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/home";
          };
        };
      };
      tank = {
        type = "zpool";
        mountpoint = null;
        rootFsOptions = {
          atime = "off";
          compression = "zstd";
        };
        datasets = {
          root = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/mnt/data";
          };
        };
      };
    };
  };
}