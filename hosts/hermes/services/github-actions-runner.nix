{ pkgs, ... }:
let
  containerName = "github-runner-cardmystic";
  imageName = "localhost/cardmystic-actions-runner:2.336.0-4";
  runnerRoot = "/var/lib/github-actions-runner/cardmystic";
  tokenFile = "/var/lib/github-runner-token/cardmystic";
  runtimeTokenFile = "/run/github-actions-runner/cardmystic.token";

  buildImage = pkgs.writeShellScript "build-cardmystic-actions-runner-image" ''
    exec ${pkgs.docker}/bin/docker build \
      --pull \
      --tag ${imageName} \
      ${./github-actions-runner-image}
  '';

  startRunner = pkgs.writeShellScript "start-cardmystic-actions-runner" ''
    set -euo pipefail

    ${pkgs.coreutils}/bin/install -d -m 0755 /run/github-actions-runner
    if [[ -s ${tokenFile} ]]; then
      ${pkgs.coreutils}/bin/install -o 1001 -g 1001 -m 0400 ${tokenFile} ${runtimeTokenFile}
    elif [[ -f ${runnerRoot}/.runner ]]; then
      ${pkgs.coreutils}/bin/install -o 1001 -g 1001 -m 0400 /dev/null ${runtimeTokenFile}
    else
      echo "A GitHub runner registration token is required for initial setup." >&2
      exit 1
    fi

    ${pkgs.docker}/bin/docker rm --force ${containerName} >/dev/null 2>&1 || true
    docker_gid="$(${pkgs.coreutils}/bin/stat --format=%g /var/run/docker.sock)"

    exec ${pkgs.docker}/bin/docker run \
      --rm \
      --name ${containerName} \
      --hostname hermes \
      --init \
      --network host \
      --group-add "$docker_gid" \
      --env DOTNET_INSTALL_DIR=${runnerRoot}/dotnet \
      --env RUNNER_LABELS=hermes \
      --env RUNNER_NAME=hermes \
      --env RUNNER_URL=https://github.com/CardMystic \
      --env RUNNER_ROOT=${runnerRoot} \
      --env RUNNER_WORK_DIRECTORY=_work \
      --volume /var/run/docker.sock:/var/run/docker.sock \
      --volume ${runnerRoot}:${runnerRoot} \
      --volume ${runtimeTokenFile}:/run/secrets/github-runner-token:ro \
      ${imageName}
  '';
in
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  systemd.services = {
    github-actions-runner-image = {
      description = "Build the CardMystic GitHub Actions runner image";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      before = [ "${containerName}.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = buildImage;
      };
    };

    ${containerName} = {
      description = "CardMystic GitHub Actions runner container";
      wantedBy = [ "multi-user.target" ];
      after = [
        "docker.service"
        "github-actions-runner-image.service"
        "network-online.target"
      ];
      requires = [
        "docker.service"
        "github-actions-runner-image.service"
      ];
      wants = [ "network-online.target" ];
      restartTriggers = [ ./github-actions-runner-image ];

      serviceConfig = {
        ExecStart = startRunner;
        ExecStop = "-${pkgs.docker}/bin/docker stop --time 30 ${containerName}";
        Restart = "always";
        RestartSec = 5;
        TimeoutStopSec = 45;
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/github-runner-token 0700 root root -"
    "d /var/lib/github-actions-runner 0755 root root -"
    "d ${runnerRoot} 0750 1001 1001 -"
  ];
}
