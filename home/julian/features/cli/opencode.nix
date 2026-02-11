{
  lib,
  pkgs,
  inputs,
  ...
}:
let
  mcp-servers-pkgs = inputs.mcp-servers-nix.packages.${pkgs.system};
in
{
  programs.opencode = {
    enable = true;
    package = pkgs.opencode;
    settings = {
      model = "github-copilot/claude-opus-4.5";
      plugin = [ "oh-my-opencode" ];
      mcp = {
        "github" = {
          type = "local";
          command = [
            (lib.getExe pkgs.github-mcp-server)
            "stdio"
          ];
          enabled = true;
        };
        "nixos" = {
          type = "local";
          command = [
            (lib.getExe pkgs.mcp-nixos)
          ];
          enabled = true;
        };
        "context7" = {
          type = "local";
          command = [
            (lib.getExe mcp-servers-pkgs.context7-mcp)
          ];
          enabled = true;
        };
      };
    };
  };

  # oh-my-opencode agent configuration
  programs.oh-my-opencode = {
    enable = true;
    agents = {
      sisyphus.model = "github-copilot/claude-opus-4.6";
      oracle.model = "github-copilot/gpt-5.2";
      explore.model = "opencode/gpt-5-nano";
      librarian.model = "opencode/big-pickle";
    };
  };
}
