{ lib, cards, layouts, ... }:
let
  inherit (lib) mkDefault;
  inherit (cards) materialLightCard materialButtonCard materialSensorCard;
  inherit (layouts) adaptiveLayout materialSection;
in
{
  # Lights dashboard view
  lightsView = {
    title = "Lights";
    path = "lights";
    icon = "mdi:lightbulb-group";
    type = "sections";
    max_columns = 3;
    
    badges = [
      {
        type = "entity";
        entity = "sensor.lights_on_count";
        show_name = true;
        show_icon = true;
        show_state = true;
      }
    ];
    
    sections = [
      # Room Lights Section
      (materialSection {
        title = "Room Lights";
        cards = [
          {
            type = "grid";
            columns = 2;
            square = false;
            cards = [
              (materialLightCard {
                entity = "light.living_room";
                name = "Living Room";
                showBrightness = true;
                showColorTemp = true;
                showColor = true;
              })
              (materialLightCard {
                entity = "light.kitchen";
                name = "Kitchen";
                showBrightness = true;
                showColorTemp = true;
              })
              (materialLightCard {
                entity = "light.dining_room";
                name = "Dining Room";
                showBrightness = true;
                showColorTemp = true;
              })
              (materialLightCard {
                entity = "light.bedroom";
                name = "Master Bedroom";
                showBrightness = true;
                showColor = true;
              })
              (materialLightCard {
                entity = "light.guest_bedroom";
                name = "Guest Bedroom";
                showBrightness = true;
              })
              (materialLightCard {
                entity = "light.office";
                name = "Office";
                showBrightness = true;
                showColorTemp = true;
              })
            ];
          }
        ];
      })
      
      # Outdoor Lights Section
      (materialSection {
        title = "Outdoor Lights";
        cards = [
          {
            type = "horizontal-stack";
            cards = [
              (materialLightCard {
                entity = "light.front_porch";
                name = "Front Porch";
              })
              (materialLightCard {
                entity = "light.back_patio";
                name = "Back Patio";
              })
              (materialLightCard {
                entity = "light.garden_lights";
                name = "Garden";
              })
            ];
          }
          (materialLightCard {
            entity = "light.driveway";
            name = "Driveway";
          })
        ];
      })
      
      # Light Groups Section
      (materialSection {
        title = "Light Groups";
        cards = [
          {
            type = "vertical-stack";
            cards = [
              (materialButtonCard {
                entity = "light.all_lights";
                name = "All Lights";
                icon = "mdi:lightbulb-group";
                color = "var(--primary-color)";
              })
              (materialButtonCard {
                entity = "light.main_floor";
                name = "Main Floor";
                icon = "mdi:home-floor-1";
                color = "var(--accent-color)";
              })
              (materialButtonCard {
                entity = "light.upstairs";
                name = "Upstairs";
                icon = "mdi:home-floor-2";
                color = "var(--accent-color)";
              })
              (materialButtonCard {
                entity = "light.outdoor_all";
                name = "All Outdoor";
                icon = "mdi:outdoor-lamp";
                color = "var(--info-color)";
              })
            ];
          }
        ];
      })
      
      # Lighting Scenes Section
      (materialSection {
        title = "Lighting Scenes";
        cards = [
          {
            type = "grid";
            columns = 2;
            square = false;
            cards = [
              (materialButtonCard {
                entity = "scene.morning";
                name = "Morning";
                icon = "mdi:weather-sunny";
                color = "#FFA726";
                showState = false;
              })
              (materialButtonCard {
                entity = "scene.evening";
                name = "Evening";
                icon = "mdi:weather-sunset";
                color = "#FF7043";
                showState = false;
              })
              (materialButtonCard {
                entity = "scene.night";
                name = "Night";
                icon = "mdi:weather-night";
                color = "#5C6BC0";
                showState = false;
              })
              (materialButtonCard {
                entity = "scene.movie_time";
                name = "Movie Time";
                icon = "mdi:movie-open";
                color = "#8E24AA";
                showState = false;
              })
              (materialButtonCard {
                entity = "scene.party";
                name = "Party";
                icon = "mdi:party-popper";
                color = "#EC407A";
                showState = false;
              })
              (materialButtonCard {
                entity = "scene.reading";
                name = "Reading";
                icon = "mdi:book-open-page-variant";
                color = "#26A69A";
                showState = false;
              })
            ];
          }
        ];
      })
      
      # Adaptive Lighting Section
      (materialSection {
        title = "Adaptive Lighting";
        cards = [
          {
            type = "custom:bubble-card";
            card_type = "button";
            entity = "switch.adaptive_lighting";
            name = "Adaptive Lighting";
            icon = "mdi:brightness-auto";
            show_state = true;
            card_mod = {
              style = ''
                ha-card {
                  --bubble-button-border-radius: 12px;
                  --bubble-button-accent-color: var(--primary-color);
                  --bubble-button-background-color: var(--card-background-color);
                  box-shadow: var(--ha-card-box-shadow);
                }
              '';
            };
          }
          {
            type = "horizontal-stack";
            cards = [
              (materialSensorCard {
                entity = "sensor.adaptive_lighting_brightness";
                name = "Brightness";
                icon = "mdi:brightness-6";
                unit = "%";
              })
              (materialSensorCard {
                entity = "sensor.adaptive_lighting_color_temp";
                name = "Color Temp";
                icon = "mdi:palette";
                unit = "K";
              })
            ];
          }
        ];
      })
    ];
    
    # View-specific card styling
    card_mod = {
      style = ''
        /* Lights view specific styling */
        .view {
          background: var(--primary-background-color);
        }
        
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
        
        /* Light card animations */
        .bubble-card[data-state="on"] {
          animation: pulse-on 2s ease-in-out infinite alternate;
        }
        
        @keyframes pulse-on {
          from { 
            box-shadow: var(--ha-card-box-shadow);
          }
          to { 
            box-shadow: 0px 2px 8px 0px rgba(103, 80, 164, 0.3), 0px 2px 12px 2px rgba(103, 80, 164, 0.15);
          }
        }
        
        /* Scene button hover effects */
        .scene-card:hover {
          transform: translateY(-2px) scale(1.02);
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
          
          /* Grid becomes single column on mobile */
          .type-grid .cards {
            grid-template-columns: 1fr !important;
            gap: var(--spacing-sm, 8px) !important;
          }
        }
        
        @media (min-width: 769px) and (max-width: 1024px) {
          /* Grid becomes 2 columns on tablet */
          .type-grid .cards {
            grid-template-columns: repeat(2, 1fr) !important;
          }
        }
      '';
    };
  };
}