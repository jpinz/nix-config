{ pkgs, ... }:
{
  imports = [
    ./button-cards.nix
  ];
  services.home-assistant = {
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      bubble-card
      button-card
      card-mod
      mushroom
      universal-remote-card
    ];
    lovelaceConfig = {
      title = "";
      views = [
        {
          title = "";
          path = "home";
          type = "sections";
          max_columns = 4;
          theme = "Rounded";
          badges = [
            {
              type = "entity";
              show_name = true;
              show_state = true;
              show_icon = true;
              entity = "person.julian";
            }
            {
              type = "entity";
              entity = "weather.forecast_home";
              show_name = false;
              show_icon = true;
              show_state = true;
              show_entity_picture = false;
              state_content = "temperature";
            }
          ];
          header = {
            card = {
              type = "markdown";
              text_only = true;
              content = "# The Pinzers";
            };
          };
          sections = [
            {
              type = "grid";
              cards = [
                {
                  type = "custom:button-card";
                  view_layout = {
                    "grid-area" = "Kitchen";
                  };
                  template = "room_card";
                  variables = {
                    name = ''[[[ return 'Kitchen']]]'';
                    icon = "mdi:silverware-variant";
                    path = "#kitchen";
                    state = ''

                    '';
                    background = "var(--red-tint)";
                    color = "var(--red)";
                  };
                }
              ];
            }
            {
              type = "grid";
              cards = [
                {
                  type = "custom:button-card";
                  view_layout = {
                    "grid-area" = "Living Room";
                  };
                  template = "room_card";
                  variables = {
                    name = ''[[[ return 'Living Room']]]'';
                    icon = "mdi:television";
                    path = "#living-room";
                    state = ''

                    '';
                    background = "var(--blue-tint)";
                    color = "var(--blue)";
                  };
                }
              ];
            }
            {
              type = "grid";
              cards = [
                {
                  type = "custom:button-card";
                  view_layout = {
                    "grid-area" = "Julian Office";
                  };
                  template = "room_card";
                  variables = {
                    name = ''[[[ return 'Julian\'s Office']]]'';
                    icon = "mdi:chair-rolling";
                    path = "#julian-office";
                    state = ''

                    '';
                    background = "var(--green-tint)";
                    color = "var(--green)";
                  };
                }
              ];
            }
            {
              type = "grid";
              cards = [
                {
                  type = "custom:button-card";
                  view_layout = {
                    "grid-area" = "Lauren Office";
                  };
                  template = "room_card";
                  variables = {
                    name = ''[[[ return 'Lauren\'s Office']]]'';
                    icon = "mdi:brush";
                    path = "#lauren-office";
                    state = ''

                    '';
                    background = "var(--purple-tint)";
                    color = "var(--purple)";
                  };
                }
              ];
            }
            {
              type = "grid";
              cards = [
                {
                  type = "custom:button-card";
                  view_layout = {
                    "grid-area" = "Bedroom";
                  };
                  template = "room_card";
                  variables = {
                    name = ''[[[ return 'Bedroom']]]'';
                    icon = "mdi:bed";
                    path = "#bedroom";
                    state = ''

                    '';
                    background = "var(--purple-tint)";
                    color = "var(--purple)";
                  };
                }
              ];
            }
            {
              type = "grid";
              cards = [
                {
                  type = "vertical-stack";
                  cards = [
                    {
                      type = "custom:bubble-card";
                      card_type = "pop-up";
                      hash = "#kitchen";
                      show_header = true;
                      button_type = "name";
                      use_accent_color = false;
                      name = "Kitchen";
                      show_name = true;
                      show_icon = true;
                      icon = "mdi:silverware-variant";
                      card_layout = "normal";
                      margin_top_desktop = "50vh";
                      margin_top_mobile = "50vh";
                    }
                    {
                      type = "custom:bubble-card";
                      card_type = "button";
                      button_type = "slider";
                      entity = "light.hue_a19_color_003";
                      show_icon = true;
                      use_accent_color = false;
                      tap_action = {
                        action = "toggle";
                      };
                      hold_action = {
                        action = "more-info";
                      };
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
