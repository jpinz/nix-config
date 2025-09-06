{ pkgs, config, ... }:
{
  imports = [
    # ./abode.nix
    # ./blinds.nix
    ./cloud.nix
    ./default-config.nix
    # ./esphome.nix
    # ./hvac.nix
    # ./leak.nix
    # ./lights.nix
    # ./miele.nix
    ./mqtt.nix
    ./notify.nix
    # ./people.nix
    # ./recorder.nix
    # ./sonos.nix
    # ./unifi.nix
    # ./vacation.nix
    ./waste-collection.nix
    # ./weather.nix
  ];

  services.home-assistant = {
    enable = true;
    package = pkgs.home-assistant.override {
      packageOverrides = self: super: {
        python-roborock = pkgs.python3Packages.python-roborock;
      };
    };
    extraComponents = [
      "adguard"
      "androidtv_remote"
      "august"
      "cast"
      "google_translate"
      "homeassistant_hardware"
      "homeassistant_sky_connect"
      "homekit_controller"
      "hue"
      "isal"
      "lg_thinq"
      "matter"
      "met"
      "mqtt"
      "notify"
      "otp"
      "roborock"
      "spotify"
      "unifiprotect"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      adaptive_lighting
      alarmo
      better_thermostat
      climate_group
      spook
      waste_collection_schedule
    ];
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      bubble-card
      button-card
      card-mod
      lg-webos-remote-control
      mushroom
      universal-remote-card
    ];
    config = {
      http = {
        trusted_proxies = [
          "127.0.0.1"
          "::1"
        ];
        use_x_forwarded_for = true;
      };
      homeassistant = {
        auth_mfa_modules = [
          { type = "totp"; }
          { type = "notify"; }
        ];
      };
      lovelace = {
        mode = "yaml";
      };
      "automation manual" = [ ];
      "automation ui" = "!include automations.yaml";
      "scene manual" = [ ];
      "scene ui" = "!include scenes.yaml";
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/secrets.yaml 0755 hass hass"
  ];
}
