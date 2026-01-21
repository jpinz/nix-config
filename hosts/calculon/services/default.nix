{ config, ... }:
{
  imports = [

  ];

  users.groups.services.members = with config.services; [

  ];

}
