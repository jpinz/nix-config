{ pkgs, ... }:
{
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
          max_columns = 1;
          badges = [
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
              name = "";
              cards = [
                {
                  type = "custom:mushroom-light-card";
                  entity = "light.living_room";
                  fill_container = false;
                  use_light_color = true;
                  show_brightness_control = true;
                  show_color_control = true;
                  show_color_temp_control = true;
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
