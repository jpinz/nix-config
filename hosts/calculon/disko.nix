{
  disko.devices = {
    disk = {
      hdd0 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD80EFAX-68LHPN0_7SGH1MDC";
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
      hdd1 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD80EMAZ-00WJTA0_1EHVGXHZ";
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
      hdd2 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-WDC_WD80EFAX-68LHPN0_7SGGTZ9C";
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
      tank = {
        type = "zpool";
        mode = "raidz";
        mountpoint = null;
        options.ashift = "12";
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
