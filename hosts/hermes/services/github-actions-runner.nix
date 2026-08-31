{ ... }:
{
  services.github-runners.cardmystic-platform = {
    enable = true;
    name = "hermes";
    url = "https://github.com/CardMystic/cardmystic-platform";
    tokenFile = "/var/lib/github-runner-token/cardmystic-platform";
    extraLabels = [ "hermes" ];
    replace = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/github-runner-token 0700 root root -"
  ];
}
