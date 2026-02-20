{ config, ... }:
{
  services.samba = {
    enable = true;
    openFirewall = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = config.networking.hostName;
        "netbios name" = config.networking.hostName;
        "security" = "user";
        "map to guest" = "Bad User";
      };

      data = {
        path = "/mnt/data";
        browseable = "yes";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = config.users.users.julian.name;
        "force user" = config.users.users.julian.name;
        "force group" = config.users.groups.services.name;
        "create mask" = "0660";
        "directory mask" = "2770";
      };

      downloads = {
        path = "/mnt/downloads";
        browseable = "yes";
        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "valid users" = config.users.users.julian.name;
        "force user" = config.users.users.julian.name;
        "force group" = config.users.groups.services.name;
        "create mask" = "0660";
        "directory mask" = "2770";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}
