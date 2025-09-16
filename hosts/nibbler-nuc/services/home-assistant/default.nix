{ pkgs, config, ... }:
{
  imports = [
    ./automations.nix
    ./blueprints.nix
    ./cloud.nix
    ./default-config.nix
    # ./esphome.nix
    # ./leak.nix
    # ./lights.nix
    ./lovelace.nix
    ./matter.nix
    ./mqtt.nix
    ./notify.nix
    # ./people.nix
    ./recorder.nix
    ./scenes.nix
    ./scripts.nix
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
      "cast"
      "homeassistant_hardware"
      "homeassistant_sky_connect"
      "homekit_controller"
      "isal"
      "matter"
      "met"
      "mqtt"
      "notify"
      "otbr"
      "otp"
      "roborock"
      "thread"
      "unifiprotect"
      "zeroconf"
    ];
    customComponents = with pkgs.home-assistant-custom-components; [
      adaptive_lighting
      alarmo
      # better_thermostat - Disabled due to not being able to currently add my ecobee3 lite thermostats
      # climate_group - Disabled due to not being able to currently add my ecobee3 lite thermostats
      spook
      waste_collection_schedule
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
    };
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
  networking.firewall.allowedUDPPorts = [ 8123 ];

  systemd.tmpfiles.rules = [
    "f ${config.services.home-assistant.configDir}/automations.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/scenes.yaml 0755 hass hass"
    "f ${config.services.home-assistant.configDir}/secrets.yaml 0755 hass hass"
    "d ${config.services.home-assistant.configDir}/themes 0755 hass hass"
  ];
}
