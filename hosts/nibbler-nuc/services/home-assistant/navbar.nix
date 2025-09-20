{ pkgs, ... }:
{
  services.home-assistant = {
    lovelaceConfig = {
      navbar-templates = {
        default = {
          routes = [
            {
              label = "Home";
              icon = "mdi:home";
              url = "/lovelace/home";
            }
            {
              label = "Security";
              icon = "mdi:security";
              url = "/lovelace/security";
            }
          ];
        };
      };
    };
  };
}
