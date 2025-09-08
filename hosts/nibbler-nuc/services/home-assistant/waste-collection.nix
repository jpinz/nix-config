{
  services.home-assistant.config = {
    waste_collection_schedule = {
      sources = [
        {
          name = "multiple";
          args = {
            static = [
              {
                type = "Trash";
                frequency = "WEEKLY";
                interval = 1;
                start = "2025-09-12";
                weekdays = "FR";
                excludes = [ "2026-06-19" ];
                dates = [ "2026-06-20" ];
              }
              {
                type = "Recycling";
                frequency = "WEEKLY";
                interval = 2;
                start = "2025-09-12";
                weekdays = "FR";
                excludes = [ "2026-06-19" ];
                dates = [ "2026-06-20" ];
              }
            ];
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