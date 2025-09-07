{
  services.home-assistant.config = {
    waste_collection_schedule = {
      sources = [
        {
          name = "static";
          args = {
            type = "waste";
            frequency = "WEEKLY";
            interval = 2;
            start = "2025-09-08";
            weekdays = "FR";
            excludes = [ "2026-06-19" ];
          };
        }
      ];
    };

    sensor = [
      {
        platform = "waste_collection_schedule";
        name = "Waste collection";
      }
    ];

    # automation = [
    #   {
    #     alias = "Notify waste collection";
    #     id = "notify_waste_collection";
    #     triggers = [
    #       {
    #         trigger = "calendar";
    #         event = "start";
    #         offset = "-6:00:00";
    #         entity_id = "calendar.public_utilities";
    #       }
    #     ];
    #     actions = [
    #       {
    #         action = "notify.everyone";
    #         data = {
    #           title = "Waste collection";
    #           message = "{{ states(\"sensor.waste_collection\") }}";
    #         };
    #       }
    #     ];
    #   }
    # ];
  };
}