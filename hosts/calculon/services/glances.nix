{ pkgs, ... }:
let
  configFile = pkgs.writeText "glances.conf" ''
    [outputs]
    url_prefix=/monitor/

    [folders]
    refresh=1800
    folder_1_path=/mnt/data/tv
    folder_2_path=/mnt/data/anime
    folder_3_path=/mnt/data/movies
    folder_4_path=/mnt/data/music
    folder_5_path=/mnt/data/audiobooks
    folder_6_path=/mnt/data/ebooks
    folder_7_path=/mnt/data/videos
  '';
in
{
  services.glances = {
    enable = true;
    openFirewall = false;
    extraArgs = [
      "--webserver"
      "--bind"
      "127.0.0.1"
      "--config"
      "${configFile}"
      "--disable-check-update"
    ];
  };

  systemd.services.glances.serviceConfig.SupplementaryGroups = [ "services" ];
}