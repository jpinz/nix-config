{ pkgs, ... }:
{
  services.home-assistant = {
    lovelaceConfig = {
      views = [
        {
          title = "";
          path = "security";
          type = "sections";
          max_columns = 4;
          theme = "Rounded";
          badges = [
            {
              type = "entity";
              show_name = false;
              show_state = true;
              show_icon = true;
              entity = "alarm_control_panel.alarmo";
            }
          ];
          sections = [
            {
              type = "grid";
              cards = [
                {
                  type = "custom:advanced-camera-card";
                  cameras = [
                    { camera_entity = "camera.living_room"; }
                    { camera_entity = "camera.kitchen"; }
                    { camera_entity = "camera.doorbell"; }
                  ];
                  live = {
                    display = {
                      mode = "grid";
                    };
                  };
                }
              ];
            }
            # Navbar
            {
              type = "custom:navbar-card";
              template = "default";
            }
          ];
        }
      ];
    };
  };
}
