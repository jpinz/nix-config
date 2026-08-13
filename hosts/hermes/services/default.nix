{ ... }:
{
  imports = [
    ./hermes-agent.nix
    ./hermes-dashboard.nix
    ./minecraft-project-infinity.nix
    ./ollama.nix
  ];

  users.groups.hermes = { };

  systemd.tmpfiles.rules = [
    "Z /var/lib/hermes - julian hermes - -"
  ];
}
