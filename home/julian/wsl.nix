{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./global

    ./features/cli
  ];

  home = {
    packages = with pkgs; [
      # .NET SDKs
      (
        with dotnetCorePackages;
        combinePackages [
          sdk_8_0
          sdk_9_0
          # sdk_10_0
        ]
      )

      # Node.js and package managers
      nodejs_24
      nodePackages_latest.pnpm
      nodePackages_latest.yarn

      # Go
      go_1_24

      # System tools
      wslu
    ];
  };

  programs = {
    zellij = {
      attachExistingSession = lib.mkForce false;
      exitShellOnExit = lib.mkForce false;
    };
  };
}
