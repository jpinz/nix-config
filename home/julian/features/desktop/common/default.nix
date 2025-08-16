{ pkgs, ... }:
{
  imports = [
    ./dconf.nix
    ./font.nix
    ./firefox.nix
    ./gtk.nix
    ./jetbrains.nix
    ./kitty.nix
    ./vscode.nix
  ];

  home.packages = with pkgs; [

  ];
}
