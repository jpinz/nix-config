# Shell for bootstrapping flake-enabled nix and other tooling
{
  pkgs ?
    # If pkgs is not defined, instantiate the exact locked nixpkgs input.
    let
      lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = builtins.fetchTree lock;
    in
    import nixpkgs.outPath { overlays = [ ]; },
  ...
}:
pkgs.mkShell {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  nativeBuildInputs = with pkgs; [
    nix
    home-manager
    git

    deploy-rs
    gnupg
    age
    sops
    ssh-to-age
  ];
}
