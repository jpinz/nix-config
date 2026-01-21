{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deadnix
    nh
    nil
    nix-prefetch-github
    nix-update
    nixfmt
    nixpkgs-hammering
    nixpkgs-review
    statix
    treefmt
  ];
}
