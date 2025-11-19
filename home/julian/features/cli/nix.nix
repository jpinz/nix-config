{ pkgs, ... }:
{
  home.packages = with pkgs; [
    deadnix
    nh
    nil
    nix-prefetch-github
    nix-update
    nixfmt-rfc-style
    nixpkgs-hammering
    nixpkgs-review
    statix
    treefmt
  ];
}
