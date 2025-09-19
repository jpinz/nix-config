{
  services.home-assistant.config = {
    "scene manual" = [
{
        name = "Craft Mode";
        entities = {
          "light.lr_2" = {
            state = "on";
            color_mode = "color_temp";
            brightness = 181;
            color_temp_kelvin = 2923;
            color_temp = 342;
          };
        };
      }
    ];
  };
}
