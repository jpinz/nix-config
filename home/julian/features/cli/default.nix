{ pkgs, inputs, ... }:
{
  imports = [
    ./fish.nix
    ./git.nix
    ./opencode.nix
    ./jujutsu.nix
    ./nix.nix
    ./micro.nix
    ./ssh.nix
    ./starship.nix
  ];

  home = {
    packages = with pkgs; [
      inputs.micasa.packages.${pkgs.system}.default
      deploy-rs
      fastfetch
      fd
      glances
      lazygit
      magic-wormhole
      p7zip
      ripgrep
      skopeo
      statix
      trippy
      yq-go
    ];
  };

  programs = {
    atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      daemon = {
        enable = true;
      };
      settings = {
        daemon = {
          enabled = true;
        };
      };
    };
    bat = {
      enable = true;
    };
    bottom = {
      enable = true;
    };
    eza = {
      enable = true;
    };
    fzf = {
      enable = true;
    };
    jq = {
      enable = true;
    };
    zellij = {
      enable = true;
      settings = {
        default_mode = "locked";
        theme = "dracula";
        themes = {
          nord = {
            fg = "#D8DEE9";
            bg = "#2E3440";
            black = "#3B4252";
            red = "#BF616A";
            green = "#A3BE8C";
            yellow = "#EBCB8B";
            blue = "#81A1C1";
            magenta = "#B48EAD";
            cyan = "#88C0D0";
            white = "#E5E9F0";
            orange = "#D08770";
          };
        };
        default_layout = "compact";
        pane_frames = false;
        show_startup_tips = false;
      };
    };
    zoxide = {
      enable = true;
    };
  };
}