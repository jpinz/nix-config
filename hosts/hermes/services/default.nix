{ ... }:
{
  imports = [
    ./github-actions-runner.nix
    ./minecraft-project-infinity.nix
  ];

  users.groups.hermes = { };

  systemd.tmpfiles.rules = [
    "Z /var/lib/hermes - julian hermes - -"
  ];
}
