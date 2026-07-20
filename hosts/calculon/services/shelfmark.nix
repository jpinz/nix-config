{ lib, ... }:
{
  services.shelfmark = {
    enable = true;
    openFirewall = true;
    environment = {
      FLASK_HOST = "0.0.0.0";
      FLASK_PORT = 8084;
    };
  };

  # Allow Shelfmark to write downloads into the shared ebooks library.
  # The upstream module hardens the service heavily, which blocks this:
  #   - ProtectSystem = "strict" makes /mnt read-only -> add ReadWritePaths
  #   - the dir is 2770 julian:services -> join the services group
  #   - PrivateUsers = true breaks supplementary-group file access -> disable it
  systemd.services.shelfmark.serviceConfig = {
    SupplementaryGroups = [ "services" ];
    ReadWritePaths = [ "/mnt/data/ebooks" ];
    PrivateUsers = lib.mkForce false;
    # Make uploaded files group read/write so other `services` members (julian,
    # calibre-web) can manage them. The library dir is 2770 + setgid, so new
    # files inherit the `services` group; 0007 keeps them group-writable.
    UMask = lib.mkForce "0007";
  };
}
