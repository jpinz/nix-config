{
  services.tdarr = {
    enable = true;
    group = "services";

    server = {
      enable = true;
      webUIPort = 8265;
      serverPort = 8266;
      openFirewall = true;
    };

    nodes.local = {
      enable = true;
      workers = {
        transcodeCPU = 1;
        transcodeGPU = 1;
        healthcheckCPU = 1;
        healthcheckGPU = 0;
      };
    };
  };

  # Ensure transcode cache directory exists with correct ownership
  systemd.tmpfiles.rules = [
    "d /mnt/data/transcode 2770 tdarr services -"
  ];

  # Grant tdarr access to media directories
  systemd.services.tdarr-server.serviceConfig = {
    ReadWritePaths = [ "/mnt/data" "/mnt/downloads" ];
    ReadOnlyPaths = [ "/mnt" ];
  };
  systemd.services."tdarr-node-local".serviceConfig = {
    ReadWritePaths = [ "/mnt/data" "/mnt/downloads" ];
    ReadOnlyPaths = [ "/mnt" ];
    SupplementaryGroups = [ "render" "video" ];
  };
}
