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
              description = "Closest to the Kitchen";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Ceiling Light 1";
              };
            };
            "0x001788010e9a725e" = defaultLight // {
              friendly_name = "living-room/ceiling/light-2";
              description = "Above the right side of the couch (when looking at TV)";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Ceiling Light 2";
              };
            };
            "0x001788010e9aa14b" = defaultLight // {
              friendly_name = "living-room/ceiling/light-3";
              description = "In front of the window by the couch";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Ceiling Light 3";
              };
            };
            "0x001788010e9aa165" = defaultLight // {
              friendly_name = "living-room/ceiling/light-4";
              description = "In front of the TV";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Ceiling Light 4";
              };
            };
            "0x001788010e9aa05d" = defaultLight // {
              friendly_name = "living-room/ceiling/light-5";
              description = "Above the fireplace";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Ceiling Light 5";
              };
            };
            "0x001788010e9aa1ed" = defaultLight // {
              friendly_name = "living-room/ceiling/light-6";
              description = "Outside of the bathroom";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Ceiling Light 6";
              };
            };
            "0x001788010b6cf2f7" = defaultLight // {
              friendly_name = "living-room/shelf/light-1";
              transition = 0.75;
              homeassistant = {
                # name = "Living Room Shelf Light";
              };
            };
            "0x8c8b48fffe4c5963" = defaultSwitch // {
              friendly_name = "living-room/switch";
              homeassistant = {
                # name = "Living Room Switch";
              };
            };

            # Kitchen
            "0x001788010b6cf321" = defaultLight // {
              friendly_name = "kitchen/table/light";
              transition = 0.75;
              homeassistant = {
                # name = "Kitchen Table Light";
              };
            };
            "0x00158d0009ee273d" = {
              friendly_name = "kitchen/back-door/sensor";
              homeassistant = {
                # name = "Back Door Sensor";
              };
            };

            # Dining Room
            "0x0017880108e27628" = defaultLight // {
              friendly_name = "dining-room/floor-lamp/light-top";
              transition = 0.75;
              homeassistant = {
                # name = "Dining Room Floor Lamp Top";
              };
            };
            "0x001788010ce828b1" = defaultLight // {
              friendly_name = "dining-room/floor-lamp/light-middle";
              transition = 0.75;
              homeassistant = {
                # name = "Dining Room Floor Lamp Middle";
              };
            };
            "0x001788010ce0f8ee" = defaultLight // {
              friendly_name = "dining-room/floor-lamp/light-bottom";
              transition = 0.75;
              homeassistant = {
                # name = "Dining Room Floor Lamp Bottom";
              };
            };

            # Bedroom
            "0x001788010f18f4b6" = defaultLight // {
              friendly_name = "bedroom/ceiling/light";
              transition = 0.75;
              homeassistant = {
                # name = "Bedroom Ceiling Light";
              };
            };

            # Lauren's Office
            "0x001788010c70529f" = defaultLight // {
              friendly_name = "laurens-office/ceiling/light";
              transition = 0.75;
              homeassistant = {
                # name = "Lauren's Office Ceiling Light";
              };
            };

            # Basement
            "0x00124b0025394cb5" = {
              friendly_name = "basement/thermometer";
              homeassistant = {
                # name = "Basement Thermometer";
              };
            };
          };

        groups = {
          "1" = {
            friendly_name = "group/living-room/ceiling";
            transition = 0.75;
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
