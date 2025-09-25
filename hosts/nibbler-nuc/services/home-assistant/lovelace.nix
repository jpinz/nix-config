{ pkgs, ... }:
{
  imports = [
    ./button-cards.nix
    ./lovelace/security.nix
    ./lovelace/home.nix
    ./navbar.nix
  ];
  
  services.home-assistant = {
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      advanced-camera-card
      bubble-card
      button-card
      card-mod
      material-you-utilities
      mushroom
      navbar-card
      swipe-navigation
      universal-remote-card
    ];
    lovelaceConfig = {
      title = "";
      default_view = "home";
    };
  };
}
