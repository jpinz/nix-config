{
  virtualisation.docker = {
    enable = true;
  };

  users.users.julian.extraGroups = [ "docker" ];
}
