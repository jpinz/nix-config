{ lib, config, ... }:
let
  # Import our material design theme
  materialThemes = import ./dashboard/themes/material-design.nix { };
in
{
  # Configure Home Assistant themes directory and material design themes
  systemd.tmpfiles.rules = [
    "d ${config.services.home-assistant.configDir}/themes 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/themes/material_light.yaml 0644 hass hass"
    "f ${config.services.home-assistant.configDir}/themes/material_dark.yaml 0644 hass hass"
  ];
  
  # Write material design theme files
  environment.etc = {
    "homeassistant/themes/material_light.yaml" = {
      text = lib.generators.toYAML { } {
        material_light = materialThemes.materialTheme;
      };
      mode = "0644";
    };
    
    "homeassistant/themes/material_dark.yaml" = {
      text = lib.generators.toYAML { } {
        material_dark = materialThemes.materialThemeDark;
      };
      mode = "0644";
    };
  };
  
  services.home-assistant.config = {
    # Enable frontend themes  
    frontend = {
      themes = "!include_dir_merge_named themes";
    };
  };
}