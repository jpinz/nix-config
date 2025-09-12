{ lib, ... }:
{
  systemd.services.zigbee2mqtt.serviceConfig = {
    Restart = lib.mkForce "always";
    RestartSec = "30";
  };

  services = {
    zigbee2mqtt = {
      enable = true;
      settings = {
        availability = true;
        frontend = {
          port = 8080;
        };
        serial = {
          port = "/dev/ttyUSB0";
          adapter = "ember";
        };
        advanced = {
          log_level = "warning";
        };

        devices =
          let
            defaultSwitch = {
              ledColorWhenOn = 255;
              ledIntensityWhenOn = 100;
              ledColorWhenOff = 255;
              ledIntensityWhenOff = 0;
              outputMode = "On/Off";
              smartBulbMode = "Smart Bulb Mode";
            };
            defaultLight = {
              color_temp_startup = 65535;
            };
            defaultFan = defaultSwitch // {
              outputMode = "Exhaust Fan (On/Off)";
              smartBulbMode = "Disabled";
            };
          in
          {
           # Living Room
            "0x001788010e9a7656" = defaultLight // {
              friendly_name = "living-room/ceiling/light-1";
            };
            "0x001788010e9a725e" = defaultLight // {
              friendly_name = "living-room/ceiling/light-2";
            };
            "0x001788010e9aa14b" = defaultLight // {
              friendly_name = "living-room/ceiling/light-3";
            };
            "0x001788010e9aa165" = defaultLight // {
              friendly_name = "living-room/ceiling/light-4";
            };
            "0x001788010e9aa05d" = defaultLight // {
              friendly_name = "living-room/ceiling/light-5";
            };
            "0x001788010e9aa1ed" = defaultLight // {
              friendly_name = "living-room/ceiling/light-6";
            };
            "0x001788010b6cf2f7" = defaultLight // {
              friendly_name = "living-room/shelf/light-1";
            };
            "0x8c8b48fffe4c5963" = defaultSwitch // {
              friendly_name = "living-room/switch";
            };

            # Kitchen
            "0x001788010b6cf321" = defaultLight // {
              friendly_name = "kitchen/table/light";
            };
            "0x00158d0009ee273d" = {
              friendly_name = "kitchen/backdoor/sensor";
            };

            # Dining Room
            "0x0017880108e27628" = defaultLight // {
              friendly_name = "dining-room/floor-lamp/light-top";
            };
            "0x001788010ce828b1" = defaultLight // {
              friendly_name = "dining-room/floor-lamp/light-middle";
            };
            "0x001788010ce0f8ee" = defaultLight // {
              friendly_name = "dining-room/floor-lamp/light-bottom";
            };

            # Primary Bedroom
            "0x001788010f18f4b6" = defaultLight // {
              friendly_name = "primary-bedroom/ceiling/light";
            };

            # Lauren's Office
            "0x001788010c70529f" = defaultLight // {
              friendly_name = "laurens-office/ceiling/light";
            };

            # Basement
            "0x00124b0025394cb5" = {
              friendly_name = "basement/thermometer";
            };
          };

        groups = {
          "1" = {
            friendly_name = "group/living-room/ceiling";
            devices = [
              "0x001788010e9a7656/11"
              "0x001788010e9a725e/11"
              "0x001788010e9aa14b/11"
              "0x001788010e9aa165/11"
              "0x001788010e9aa05d/11"
              "0x001788010e9aa1ed/11"
              "0x8c8b48fffe4c5963/1"
            ];
          };
        };
      };
    };
    mosquitto = {
      enable = true;
      listeners = [
        {
          settings = {
            allow_anonymous = true;
          };
          omitPasswordAuth = true;
          acl = [ "topic readwrite #" ];
          users = {
            zigbee2mqtt = {
              acl = [ "readwrite #" ];
            };
            home-assistant = {
              acl = [ "readwrite #" ];
            };
          };
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 8080 ];
}