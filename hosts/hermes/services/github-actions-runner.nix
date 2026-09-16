{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.cardmystic-runners;
  imageContext = builtins.path {
    path = ./github-actions-runner-image;
    name = "cardmystic-runner-image";
  };
  imageName = "localhost/cardmystic-actions-runner:${
    builtins.substring 0 16 (builtins.hashString "sha256" (toString imageContext))
  }";
  runnerNames = map (index: "cardmystic-${toString index}") (lib.range 1 cfg.count);
  runnerRoot = name: "/var/lib/github-actions-runner-pool/${name}";
in
{
  options.services.cardmystic-runners.count = lib.mkOption {
    type = lib.types.ints.positive;
    default = 2;
    description = "Number of isolated Ubuntu runners for CardMystic CI.";
  };

  config = {
    virtualisation.docker = {
      enable = true;
      autoPrune.enable = true;
    };

    virtualisation.oci-containers = {
      backend = "docker";
      containers = lib.genAttrs runnerNames (name: {
        image = imageName;
        pull = "never";
        serviceName = "github-runner-${name}";
        hostname = "${config.networking.hostName}-${name}";
        privileged = true;
        environment = {
          RUNNER_NAME = "${config.networking.hostName}-${name}";
          RUNNER_ORG = "CardMystic";
          RUNNER_LABELS = "hermes";
        };
        volumes = [
          "${runnerRoot name}/docker:/var/lib/docker"
          "${runnerRoot name}/cache:/runner-cache"
          "/var/lib/github-runner-token/cardmystic-pat:/run/secrets/github-runner-pat:ro"
        ];
        extraOptions = [
          "--init"
          "--cgroupns=private"
          "--shm-size=1g"
          "--stop-timeout=90"
        ];
      });
    };

    systemd.services = {
      github-actions-runner-image = {
        description = "Build the CardMystic CI runner image";
        requires = [ "docker.service" ];
        after = [
          "docker.service"
          "network-online.target"
        ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = pkgs.writeShellScript "build-cardmystic-runner-image" ''
            exec ${pkgs.docker}/bin/docker build --pull --tag ${imageName} ${imageContext}
          '';
          TimeoutStartSec = "infinity";
        };
      };
    }
    // lib.genAttrs (map (name: "github-runner-${name}") runnerNames) (_: {
      requires = [
        "docker.service"
        "github-actions-runner-image.service"
      ];
      after = [ "github-actions-runner-image.service" ];
      restartTriggers = [ imageContext ];
      serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 10;
      };
    });

    systemd.tmpfiles.rules = [
      "d /var/lib/github-runner-token 0700 root root -"
      "d /var/lib/github-actions-runner-pool 0700 root root -"
    ]
    ++ lib.concatMap (name: [
      "d ${runnerRoot name} 0700 root root -"
      "d ${runnerRoot name}/docker 0700 root root -"
      "d ${runnerRoot name}/cache 0750 1001 1001 -"
    ]) runnerNames;
  };
}
