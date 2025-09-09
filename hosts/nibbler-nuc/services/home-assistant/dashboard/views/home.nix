{ lib, cards, layouts, ... }:
let
  inherit (lib) mkDefault;
  inherit (cards) materialButtonCard materialLightCard materialSensorCard materialWeatherCard;
  inherit (layouts) adaptiveLayout materialSection;
in
{
  # Home dashboard view - main overview
  homeView = {
    title = "Home";
    path = "home";
    icon = "mdi:home";
    type = "sections";
    max_columns = 3;
    
    # Mobile-friendly badges in header
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
      {
        type = "entity";
        entity = "sensor.date_time";
        show_name = false;
        show_icon = false;
        show_state = true;
      }
    ];
    
    # Welcome header with material design styling
    header = {
      type = "custom:bubble-card";
      card_type = "separator";
      name = "Welcome Home";
      icon = "mdi:home-heart";
      card_mod = {
        style = ''
          ha-card {
            --bubble-separator-background-color: transparent;
            --bubble-separator-text-color: var(--primary-text-color);
            --bubble-separator-icon-color: var(--primary-color);
            border: none;
            box-shadow: none;
            margin-bottom: var(--spacing-lg, 16px);
          }
          
          .bubble-separator .bubble-name {
            font-size: 1.5em;
            font-weight: 600;
          }
          
          @media (max-width: 768px) {
            .bubble-separator .bubble-name {
              font-size: 1.3em;
            }
          }
        '';
      };
    };
    
    sections = [
      # Quick Controls Section
      (materialSection {
        title = "Quick Controls";
        cards = [
          # Lights quick controls in horizontal layout
          {
            type = "horizontal-stack";
            cards = [
              (materialLightCard {
                entity = "light.living_room";
                name = "Living Room";
              })
              (materialLightCard {
                entity = "light.kitchen";
                name = "Kitchen";
              })
              (materialLightCard {
                entity = "light.bedroom";
                name = "Bedroom";
              })
            ];
          }
          # Climate and security controls
          {
            type = "horizontal-stack";
            cards = [
              (materialButtonCard {
                entity = "climate.main_thermostat";
                name = "Climate";
                icon = "mdi:thermostat";
                color = "var(--info-color)";
              })
              (materialButtonCard {
                entity = "alarm_control_panel.home_security";
                name = "Security";
                icon = "mdi:shield-home";
                color = "var(--warning-color)";
              })
            ];
          }
        ];
      })
      
      # Weather & Environment Section
      (materialSection {
        title = "Weather & Environment";
        cards = [
          (materialWeatherCard {
            entity = "weather.forecast_home";
          })
          {
            type = "horizontal-stack";
            cards = [
              (materialSensorCard {
                entity = "sensor.indoor_temperature";
                name = "Indoor";
                icon = "mdi:thermometer";
              })
              (materialSensorCard {
                entity = "sensor.indoor_humidity";
                name = "Humidity";
                icon = "mdi:water-percent";
              })
              (materialSensorCard {
                entity = "sensor.outdoor_temperature";
                name = "Outdoor";
                icon = "mdi:thermometer-lines";
              })
            ];
          }
        ];
      })
      
      # Energy & Utilities Section  
      (materialSection {
        title = "Energy & Utilities";
        cards = [
          {
            type = "horizontal-stack";
            cards = [
              (materialSensorCard {
                entity = "sensor.energy_usage_today";
                name = "Energy Today";
                icon = "mdi:flash";
                unit = "kWh";
              })
              (materialSensorCard {
                entity = "sensor.water_usage_today";
                name = "Water Today";
                icon = "mdi:water";
                unit = "gal";
              })
            ];
          }
          # Energy history chart
          {
            type = "custom:bubble-card";
            card_type = "button";
            entity = "sensor.energy_usage_weekly";
            name = "Energy Usage";
            icon = "mdi:chart-line";
            show_attribute = true;
            attribute = "friendly_name";
            card_mod = {
              style = ''
                ha-card {
                  --bubble-button-border-radius: 12px;
                  --bubble-button-background-color: var(--card-background-color);
                  box-shadow: var(--ha-card-box-shadow);
                }
              '';
            };
          }
        ];
      })
      
      # Devices & Status Section
      (materialSection {
        title = "Device Status";
        cards = [
          {
            type = "horizontal-stack";
            cards = [
              (materialSensorCard {
                entity = "sensor.devices_online";
                name = "Online";
                icon = "mdi:check-network-outline";
              })
              (materialSensorCard {
                entity = "sensor.devices_battery_low";
                name = "Low Battery";
                icon = "mdi:battery-alert-variant-outline";
              })
              (materialSensorCard {
                entity = "sensor.updates_available";
                name = "Updates";
                icon = "mdi:update";
              })
            ];
          }
        ];
      })
    ];
    
    # Global card styling for the view
    card_mod = {
      style = ''
        :host {
          --ha-card-box-shadow: 0px 1px 2px 0px rgba(0, 0, 0, 0.3), 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
          --ha-card-border-radius: 12px;
        }
        
        /* View container styling */
        .view {
          background: var(--primary-background-color);
          transition: background-color 0.3s ease;
        }
        
        /* Section spacing */
        .sections {
          gap: var(--spacing-lg, 16px);
          padding: var(--spacing-lg, 16px);
        }
        
        .section {
          background: var(--secondary-background-color);
          border-radius: var(--ha-card-border-radius);
          padding: var(--spacing-lg, 16px);
          box-shadow: var(--ha-card-box-shadow);
          transition: all 0.3s ease;
        }
        
        .section:hover {
          transform: translateY(-1px);
          box-shadow: 0px 2px 4px 0px rgba(0, 0, 0, 0.4), 0px 2px 6px 2px rgba(0, 0, 0, 0.2);
        }
        
        /* Mobile responsive adjustments */
        @media (max-width: 768px) {
          .sections {
            gap: var(--spacing-md, 12px);
            padding: var(--spacing-md, 12px);
          }
          
          .section {
            padding: var(--spacing-md, 12px);
          }
          
          /* Stack horizontal cards vertically on mobile */
          horizontal-stack .card-content {
            flex-direction: column !important;
            gap: var(--spacing-sm, 8px) !important;
          }
          
          horizontal-stack .card-content > * {
            flex: none !important;
            width: 100% !important;
          }
        }
      '';
    };
  };
}