{ config, pkgs, ... }:
{
  virtualisation.podman = {
    enable = true;
    autoPrune.enable = true;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      romm = {
        image = "docker.io/rommapp/romm:5.4.0";
        autoStart = true;
        dependsOn = [ "romm-db" ];
        networks = [ "romm" ];
        environment = {
          TZ = "America/New_York";
          DB_HOST = "romm-db";
          DB_NAME = "romm";
          DB_USER = "romm";
          HASHEOUS_API_ENABLED = "true";
        };
        environmentFiles = [ "/var/lib/romm/secrets/romm.env" ];
        ports = [ "8085:8080" ];
        volumes = [
          "/mnt/data/roms:/romm/library"
          "/var/lib/romm/assets:/romm/assets"
          "/var/lib/romm/config:/romm/config"
          "romm-resources:/romm/resources"
          "romm-redis-data:/redis-data"
        ];
      };

      romm-db = {
        image = "docker.io/library/mariadb:11.4";
        autoStart = true;
        networks = [ "romm" ];
        environment = {
          MARIADB_DATABASE = "romm";
          MARIADB_USER = "romm";
        };
        environmentFiles = [ "/var/lib/romm/secrets/db.env" ];
        volumes = [ "romm-mysql:/var/lib/mysql" ];
        # Delay dependent services until MariaDB is ready, not merely running.
        podman.sdnotify = "healthy";
        extraOptions = [
          "--health-cmd=healthcheck.sh --connect --innodb_initialized"
          "--health-start-period=30s"
          "--health-interval=10s"
          "--health-timeout=5s"
          "--health-retries=5"
          "--health-on-failure=kill"
        ];
      };
    };
  };

  systemd.services = {
    romm-init = {
      description = "Prepare RomM network and persistent credentials";
      before = [
        "podman-romm.service"
        "podman-romm-db.service"
      ];
      after = [ "systemd-tmpfiles-setup.service" ];
      path = [
        config.virtualisation.podman.package
        pkgs.coreutils
        pkgs.openssl
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "romm";
        StateDirectoryMode = "0700";
        UMask = "0077";
      };
      script = ''
        podman network create --ignore romm

        if [ -e /var/lib/romm/secrets ]; then
          if [ ! -s /var/lib/romm/secrets/db.env ] || [ ! -s /var/lib/romm/secrets/romm.env ]; then
            echo "RomM credentials are incomplete; restore /var/lib/romm/secrets from backup." >&2
            exit 1
          fi
          exit 0
        fi

        # Publish both files together so an interrupted first start cannot split credentials.
        tmp=$(mktemp -d /var/lib/romm/.secrets.XXXXXX)
        trap 'rm -f "$tmp/db.env" "$tmp/romm.env"; rmdir "$tmp"' EXIT
        db_password=$(openssl rand -hex 32)
        root_password=$(openssl rand -hex 32)
        auth_secret=$(openssl rand -hex 32)
        printf 'MARIADB_PASSWORD=%s\nMARIADB_ROOT_PASSWORD=%s\n' \
          "$db_password" "$root_password" > "$tmp/db.env"
        printf 'DB_PASSWD=%s\nROMM_AUTH_SECRET_KEY=%s\n' \
          "$db_password" "$auth_secret" > "$tmp/romm.env"
        mv -T "$tmp" /var/lib/romm/secrets
        trap - EXIT
      '';
    };

    podman-romm = {
      requires = [ "romm-init.service" ];
      after = [ "romm-init.service" ];
      partOf = [ "podman-romm-db.service" ];
      unitConfig.RequiresMountsFor = [ "/mnt/data/roms" ];
    };
    podman-romm-db = {
      requires = [ "romm-init.service" ];
      wants = [ "podman-romm.service" ];
      after = [ "romm-init.service" ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/romm 0700 root root -"
    "d /var/lib/romm/assets 0750 root root -"
    "d /var/lib/romm/config 0750 root root -"
    "d /mnt/data/roms 2770 ${config.users.users.julian.name} services -"
    "d /mnt/data/roms/roms 2770 ${config.users.users.julian.name} services -"
    "d /mnt/data/roms/bios 2770 ${config.users.users.julian.name} services -"
  ];
}
