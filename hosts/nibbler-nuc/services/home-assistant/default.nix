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
    # ./mqtt.nix
    # ./notify.nix
    # ./people.nix
    # ./recorder.nix
    # ./sonos.nix
    # ./unifi.nix
    # ./vacation.nix
    # ./waste-collection.nix
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
      "homeassistant_hardware"
      "homeassistant_sky_connect"
      "isal"
      "cast"
      "androidtv_remote"
      "adguard"
      "met"
      "roborock"
      "notify"
    ];
    customComponents = [ ];
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
