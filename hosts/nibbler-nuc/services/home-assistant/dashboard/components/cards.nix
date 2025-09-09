{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  # Reusable card component functions for Home Assistant dashboard
  
  # Material Design Button Card using card-mod for styling
  materialButtonCard = { entity, name ? null, icon ? null, color ? "var(--primary-color)", size ? "40px", showState ? true }: {
    type = "custom:button-card";
    entity = entity;
    name = mkDefault name;
    icon = mkDefault icon;
    show_state = showState;
    show_name = true;
    tap_action = {
      action = "toggle";
    };
    card_mod = {
      style = ''
        ha-card {
          border-radius: var(--ha-card-border-radius, 12px);
          box-shadow: var(--ha-card-box-shadow);
          background: var(--card-background-color);
          transition: all 0.3s ease;
        }
        ha-card:hover {
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
          transform: translateY(-1px);
        }
        .icon {
          color: ${color};
          width: ${size};
          height: ${size};
        }
        .name {
          font-weight: 500;
          color: var(--primary-text-color);
        }
        .state {
          color: var(--secondary-text-color);
          font-size: 0.9em;
        }
      '';
    };
  };
  
  # Material Design Light Card with bubble-card styling
  materialLightCard = { entity, name ? null, showBrightness ? true, showColorTemp ? true, showColor ? true }: {
    type = "custom:bubble-card";
    card_type = "button";
    entity = entity;
    name = mkDefault name;
    show_name = true;
    show_state = true;
    show_icon = true;
    button_type = "switch";
    card_mod = {
      style = ''
        ha-card {
          --bubble-button-border-radius: 12px;
          --bubble-button-accent-color: var(--primary-color);
          --bubble-button-background-color: var(--card-background-color);
          --bubble-button-text-color: var(--primary-text-color);
          box-shadow: var(--ha-card-box-shadow);
          transition: all 0.3s ease;
        }
        ha-card:hover {
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
          transform: translateY(-1px);
        }
      '';
    };
    sub_button = lib.optionals showBrightness [
      {
        name = "Brightness";
        icon = "mdi:brightness-6";
        tap_action = {
          action = "more-info";
        };
      }
    ] ++ lib.optionals showColorTemp [
      {
        name = "Color Temp";
        icon = "mdi:palette";
        tap_action = {
          action = "more-info";
        };
      }
    ];
  };
  
  # Material Design Climate Card
  materialClimateCard = { entity, name ? null }: {
    type = "custom:bubble-card";
    card_type = "climate";
    entity = entity;
    name = mkDefault name;
    show_name = true;
    show_state = true;
    show_icon = true;
    card_mod = {
      style = ''
        ha-card {
          --bubble-climate-border-radius: 12px;
          --bubble-climate-accent-color: var(--primary-color);
          --bubble-climate-background-color: var(--card-background-color);
          --bubble-climate-text-color: var(--primary-text-color);
          box-shadow: var(--ha-card-box-shadow);
          transition: all 0.3s ease;
        }
        ha-card:hover {
          transform: translateY(-1px);
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
        }
      '';
    };
  };
  
  # Material Design Media Card
  materialMediaCard = { entity, name ? null }: {
    type = "custom:bubble-card";
    card_type = "media-player";
    entity = entity;
    name = mkDefault name;
    show_name = true;
    show_state = true;
    show_icon = true;
    card_mod = {
      style = ''
        ha-card {
          --bubble-media-border-radius: 12px;
          --bubble-media-accent-color: var(--primary-color);
          --bubble-media-background-color: var(--card-background-color);
          --bubble-media-text-color: var(--primary-text-color);
          box-shadow: var(--ha-card-box-shadow);
          transition: all 0.3s ease;
        }
        ha-card:hover {
          transform: translateY(-1px);
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
        }
      '';
    };
  };
  
  # Material Design Sensor Card
  materialSensorCard = { entity, name ? null, icon ? null, unit ? null }: {
    type = "custom:button-card";
    entity = entity;
    name = mkDefault name;
    icon = mkDefault icon;
    show_state = true;
    show_name = true;
    show_units = unit != null;
    tap_action = {
      action = "more-info";
    };
    card_mod = {
      style = ''
        ha-card {
          border-radius: var(--ha-card-border-radius, 12px);
          box-shadow: var(--ha-card-box-shadow);
          background: var(--card-background-color);
          transition: all 0.3s ease;
          cursor: pointer;
        }
        ha-card:hover {
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
          transform: translateY(-1px);
        }
        .icon {
          color: var(--state-icon-color);
        }
        .name {
          font-weight: 500;
          color: var(--primary-text-color);
        }
        .state {
          color: var(--primary-color);
          font-size: 1.2em;
          font-weight: 600;
        }
      '';
    };
  };
  
  # Material Design Weather Card
  materialWeatherCard = { entity }: {
    type = "weather-forecast";
    entity = entity;
    name = "Weather";
    show_forecast = true;
    card_mod = {
      style = ''
        ha-card {
          border-radius: var(--ha-card-border-radius, 12px);
          box-shadow: var(--ha-card-box-shadow);
          background: var(--card-background-color);
          transition: all 0.3s ease;
        }
        ha-card:hover {
          transform: translateY(-1px);
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
        }
        .content {
          color: var(--primary-text-color);
        }
        .name {
          font-weight: 500;
        }
      '';
    };
  };
  
  # Material Design Entity Row
  materialEntityRow = { entity, name ? null, icon ? null }: {
    entity = entity;
    name = mkDefault name;
    icon = mkDefault icon;
    card_mod = {
      style = ''
        :host {
          --paper-item-icon-color: var(--state-icon-color);
          --paper-item-icon-active-color: var(--state-icon-active-color);
          --primary-text-color: var(--primary-text-color);
          --secondary-text-color: var(--secondary-text-color);
        }
        state-badge {
          transition: all 0.3s ease;
        }
        .info {
          transition: all 0.3s ease;
        }
        hui-generic-entity-row:hover state-badge {
          transform: scale(1.1);
        }
      '';
    };
  };
  
  # Material Design Section Card
  materialSection = { title, cards ? [], entities ? [] }: {
    type = "custom:bubble-card";
    card_type = "separator";
    name = title;
    icon = "mdi:view-dashboard";
    card_mod = {
      style = ''
        ha-card {
          --bubble-separator-border-radius: 12px;
          --bubble-separator-background-color: var(--secondary-background-color);
          --bubble-separator-text-color: var(--primary-text-color);
          margin-bottom: var(--spacing-md, 12px);
          box-shadow: var(--ha-card-box-shadow);
        }
      '';
    };
  } // lib.optionalAttrs (cards != []) {
    inherit cards;
  } // lib.optionalAttrs (entities != []) {
    inherit entities;
  };
}