{ config, ... }:
{
  imports = [

  ];

  users.groups.services.members = with config.services; [

  ];

  systemd.tmpfiles.rules = [
    "d /mnt/downloads/incomplete 0770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/downloads/complete 0770 ${config.users.users.julian.name} ${config.users.groups.services.name}"

    "d /mnt/data/tv 0770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
    "d /mnt/data/movies 0770 ${config.users.users.julian.name} ${config.users.groups.services.name}"
  ];
}
