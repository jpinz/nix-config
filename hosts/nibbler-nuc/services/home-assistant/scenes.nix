{
  imports = [
    ./scenes/craft-mode.nix
  ];
  services.home-assistant.config = {
    "scene manual" = [

    ];
    "scene ui" = "!include scenes.yaml";
  };
}
