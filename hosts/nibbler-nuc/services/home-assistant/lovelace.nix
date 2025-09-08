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
      title = "Home";
      views = [
        {
          title = "Home";
          cards = [
            {
              show_current = true;
              show_forecast = true;
              type = "weather-forecast";
              entity = "weather.forecast_home";
              forecast_type = "daily";
            }
          ];
        }
      ];
    };
  };
}