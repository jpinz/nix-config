{
  services.home-assistant.config = {
    notify = [
      {
        platform = "group";
        name = "Everyone";
        services = [
          { service = "mobile_app_julian_s_pixel"; }
          { service = "mobile_app_lauren_s_pixel"; }
        ];
      }
    ];
  };
}