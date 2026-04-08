{
  services.navidrome = {
    enable = true;
    group = "services";

    settings = {
      Address = "127.0.0.1";
      Port = 4533;
      MusicFolder = "/mnt/data/music";
      BaseUrl = "/navidrome";
    };
  };
}
