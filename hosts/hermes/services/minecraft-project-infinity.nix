{ pkgs, ... }:

let
  version = "0.0.51.2";
  dataDir = "/var/lib/minecraft-project-infinity";

  serverFiles = pkgs.fetchurl {
    url = "https://mediafilez.forgecdn.net/files/8626/997/Serverfiles_Project_Infinity_0_1_0.0.51.2.zip";
    hash = "sha256-xF4fFvg5iQQLNxQNqnlHsqRSr6Hu/qwvS51EduomZ0A=";
  };

  forgeInstaller = pkgs.fetchurl {
    url = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.20.1-47.4.20/forge-1.20.1-47.4.20-installer.jar";
    hash = "sha256-DrzxmGCfkl4AGIQqeUc+90/aeFNPhtgvLA/bJkScH6Q=";
  };
in
{
  users.users.minecraft-project-infinity = {
    isSystemUser = true;
    group = "minecraft-project-infinity";
    home = dataDir;
  };
  users.groups.minecraft-project-infinity = { };

  systemd.services.minecraft-project-infinity = {
    description = "HerchWangPinz";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    path = [
      pkgs.gnused
      pkgs.jdk17_headless
      pkgs.unzip
    ];

    preStart = ''
      if [[ ! -e .project-infinity-${version} ]]; then
        unzip -q -o ${serverFiles} -d .
        touch .project-infinity-${version}
      fi

      if [[ ! -e libraries/net/minecraftforge/forge/1.20.1-47.4.20/unix_args.txt ]]; then
        java -jar ${forgeInstaller} --installServer
      fi

      cat > user_jvm_args.txt <<'EOF'
      -Xms6G
      -Xmx12G
      -XX:+UseG1GC
      -XX:+ParallelRefProcEnabled
      -XX:MaxGCPauseMillis=200
      -XX:+DisableExplicitGC
      -XX:+AlwaysPreTouch
      -Dlog4j2.formatMsgNoLookups=true
      EOF

      echo 'eula=true' > eula.txt
      sed -i 's/^allow-flight=.*/allow-flight=true/' server.properties
    '';

    serviceConfig = {
      User = "minecraft-project-infinity";
      Group = "minecraft-project-infinity";
      WorkingDirectory = dataDir;
      StateDirectory = "minecraft-project-infinity";
      StateDirectoryMode = "0750";
      ExecStart = "${pkgs.jdk17_headless}/bin/java @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.20.1-47.4.20/unix_args.txt nogui";
      Restart = "on-failure";
      RestartSec = 10;
      SuccessExitStatus = "0 130 143";
      TimeoutStartSec = 600;
      TimeoutStopSec = 120;
    };
  };

  networking.firewall.allowedTCPPorts = [ 25565 ];
}
