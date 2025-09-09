{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
  
  # Import modular components
  themes = import ./themes/material-design.nix { };
  cards = import ./components/cards.nix { inherit lib; };
  layouts = import ./components/layouts.nix { inherit lib; };
  
  # Import views
  homeView = import ./views/home.nix { inherit lib cards layouts; };
  lightsView = import ./views/lights.nix { inherit lib cards layouts; };
  
  # Helper function to create navigation
  createNavigation = {
    type = "custom:bubble-card";
    card_type = "horizontal-buttons-stack";
    name = "";
    card_mod = {
      style = ''
        ha-card {
          --bubble-horizontal-buttons-stack-border-radius: 0px 0px 12px 12px;
          --bubble-horizontal-buttons-stack-background-color: var(--sidebar-background-color);
          position: sticky;
          top: 0;
          z-index: 1000;
          box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .bubble-horizontal-buttons-stack .bubble-button {
          --bubble-button-background-color: transparent;
          --bubble-button-text-color: var(--sidebar-text-color);
          border-radius: 8px;
          margin: var(--spacing-xs, 4px);
          transition: all 0.3s ease;
        }
        
        .bubble-horizontal-buttons-stack .bubble-button[data-selected="true"] {
          --bubble-button-background-color: var(--sidebar-selected-background-color);
          --bubble-button-text-color: var(--sidebar-selected-text-color);
        }
        
        .bubble-horizontal-buttons-stack .bubble-button:hover {
          transform: translateY(-1px);
          background: var(--bubble-button-background-color, rgba(103, 80, 164, 0.1)) !important;
        }
        
        @media (max-width: 768px) {
          .bubble-horizontal-buttons-stack {
            position: fixed !important;
            bottom: 0 !important;
            left: 0 !important;
            right: 0 !important;
            top: auto !important;
            border-radius: 12px 12px 0px 0px !important;
          }
          
          /* Add padding to body to account for fixed navigation */
          body {
            padding-bottom: 60px !important;
          }
        }
      '';
    };
    button = [
      {
        name = "Home";
        icon = "mdi:home";
        tap_action = {
          action = "navigate";
          navigation_path = "/lovelace/home";
        };
      }
      {
        name = "Lights";
        icon = "mdi:lightbulb-group";
        tap_action = {
          action = "navigate";
          navigation_path = "/lovelace/lights";
        };
      }
      {
        name = "Climate";
        icon = "mdi:thermostat";
        tap_action = {
          action = "navigate";
          navigation_path = "/lovelace/climate";
        };
      }
      {
        name = "Security";
        icon = "mdi:shield-home";
        tap_action = {
          action = "navigate";
          navigation_path = "/lovelace/security";
        };
      }
      {
        name = "Media";
        icon = "mdi:play-circle";
        tap_action = {
          action = "navigate";
          navigation_path = "/lovelace/media";
        };
      }
    ];
  };
  
in
{
  services.home-assistant = {
    # Enhanced custom lovelace modules for material design
    customLovelaceModules = with pkgs.home-assistant-custom-lovelace-modules; [
      bubble-card
      button-card
      card-mod
      mushroom
      universal-remote-card
      mini-graph-card
      mini-media-player
      weather-card
      decluttering-card
    ];
    
    # Main lovelace configuration with material design theming
    lovelaceConfig = {
      title = "Smart Home";
      
      # Global card-mod styling for material design
      card_mod = {
        theme = "*";
        style = ''
          /* Global CSS Variables for Material Design */
          :root {
            /* Material Design 3 Color Tokens */
            --md-sys-color-primary: #6750A4;
            --md-sys-color-primary-container: #EADDFF;
            --md-sys-color-secondary: #625B71;
            --md-sys-color-secondary-container: #E8DEF8;
            --md-sys-color-surface: #FFFBFE;
            --md-sys-color-surface-variant: #E7E0EC;
            --md-sys-color-background: #FFFBFE;
            --md-sys-color-on-primary: #FFFFFF;
            --md-sys-color-on-primary-container: #21005D;
            --md-sys-color-on-secondary: #FFFFFF;
            --md-sys-color-on-secondary-container: #1D192B;
            --md-sys-color-on-surface: #1C1B1F;
            --md-sys-color-on-surface-variant: #49454F;
            --md-sys-color-on-background: #1C1B1F;
            --md-sys-color-outline: #79747E;
            
            /* Material Design Typography */
            --md-sys-typescale-display-large-font-size: 57px;
            --md-sys-typescale-display-large-line-height: 64px;
            --md-sys-typescale-headline-large-font-size: 32px;
            --md-sys-typescale-headline-large-line-height: 40px;
            --md-sys-typescale-title-large-font-size: 22px;
            --md-sys-typescale-title-large-line-height: 28px;
            --md-sys-typescale-body-large-font-size: 16px;
            --md-sys-typescale-body-large-line-height: 24px;
            --md-sys-typescale-label-large-font-size: 14px;
            --md-sys-typescale-label-large-line-height: 20px;
            
            /* Material Design Shape Tokens */
            --md-sys-shape-corner-extra-small: 4px;
            --md-sys-shape-corner-small: 8px;
            --md-sys-shape-corner-medium: 12px;
            --md-sys-shape-corner-large: 16px;
            --md-sys-shape-corner-extra-large: 28px;
            
            /* Material Design Elevation */
            --md-sys-elevation-level0: 0px 0px 0px 0px rgba(0, 0, 0, 0.00), 0px 0px 0px 0px rgba(0, 0, 0, 0.00);
            --md-sys-elevation-level1: 0px 1px 2px 0px rgba(0, 0, 0, 0.30), 0px 1px 3px 1px rgba(0, 0, 0, 0.15);
            --md-sys-elevation-level2: 0px 1px 2px 0px rgba(0, 0, 0, 0.30), 0px 2px 6px 2px rgba(0, 0, 0, 0.15);
            --md-sys-elevation-level3: 0px 4px 8px 3px rgba(0, 0, 0, 0.15), 0px 1px 3px rgba(0, 0, 0, 0.30);
            --md-sys-elevation-level4: 0px 6px 10px 4px rgba(0, 0, 0, 0.15), 0px 2px 3px rgba(0, 0, 0, 0.30);
            --md-sys-elevation-level5: 0px 8px 12px 6px rgba(0, 0, 0, 0.15), 0px 4px 4px rgba(0, 0, 0, 0.30);
          }
          
          /* Global Material Design Styles */
          * {
            font-family: 'Roboto', sans-serif !important;
          }
          
          body {
            background: var(--md-sys-color-background) !important;
            color: var(--md-sys-color-on-background) !important;
          }
          
          /* Default card styling */
          ha-card {
            background: var(--md-sys-color-surface) !important;
            color: var(--md-sys-color-on-surface) !important;
            border-radius: var(--md-sys-shape-corner-medium) !important;
            box-shadow: var(--md-sys-elevation-level1) !important;
            border: none !important;
            transition: all 0.3s cubic-bezier(0.4, 0.0, 0.2, 1) !important;
          }
          
          ha-card:hover {
            box-shadow: var(--md-sys-elevation-level2) !important;
            transform: translateY(-1px) !important;
          }
          
          /* Typography classes */
          .md-headline-large {
            font-size: var(--md-sys-typescale-headline-large-font-size) !important;
            line-height: var(--md-sys-typescale-headline-large-line-height) !important;
            font-weight: 400 !important;
          }
          
          .md-title-large {
            font-size: var(--md-sys-typescale-title-large-font-size) !important;
            line-height: var(--md-sys-typescale-title-large-line-height) !important;
            font-weight: 500 !important;
          }
          
          .md-body-large {
            font-size: var(--md-sys-typescale-body-large-font-size) !important;
            line-height: var(--md-sys-typescale-body-large-line-height) !important;
            font-weight: 400 !important;
          }
          
          .md-label-large {
            font-size: var(--md-sys-typescale-label-large-font-size) !important;
            line-height: var(--md-sys-typescale-label-large-line-height) !important;
            font-weight: 500 !important;
          }
          
          /* Responsive breakpoints */
          @media (max-width: 768px) {
            .view {
              padding: var(--spacing-sm, 8px) !important;
            }
            
            .sections {
              gap: var(--spacing-sm, 8px) !important;
              padding: var(--spacing-sm, 8px) !important;
            }
          }
          
          @media (min-width: 769px) and (max-width: 1024px) {
            .view {
              padding: var(--spacing-md, 12px) !important;
            }
            
            .sections {
              gap: var(--spacing-md, 12px) !important; 
              padding: var(--spacing-md, 12px) !important;
            }
          }
          
          @media (min-width: 1025px) {
            .view {
              padding: var(--spacing-lg, 16px) !important;
            }
            
            .sections {
              gap: var(--spacing-lg, 16px) !important;
              padding: var(--spacing-lg, 16px) !important;
            }
          }
        '';
      };
      
      # Dashboard views with material design and responsive layouts
      views = [
        # Home Dashboard View
        homeView.homeView
        
        # Lights Dashboard View  
        lightsView.lightsView
        
        # Climate Dashboard View (placeholder for future implementation)
        {
          title = "Climate";
          path = "climate";
          icon = "mdi:thermostat";
          type = "sections";
          max_columns = 2;
          sections = [
            {
              title = "Climate Control";
              cards = [
                {
                  type = "custom:bubble-card";
                  card_type = "climate";
                  entity = "climate.main_thermostat";
                  name = "Main Thermostat";
                  card_mod = {
                    style = ''
                      ha-card {
                        --bubble-climate-border-radius: 12px;
                        --bubble-climate-background-color: var(--md-sys-color-surface);
                        box-shadow: var(--md-sys-elevation-level1);
                      }
                    '';
                  };
                }
              ];
            }
          ];
        }
        
        # Security Dashboard View (placeholder for future implementation)
        {
          title = "Security";
          path = "security";
          icon = "mdi:shield-home";
          type = "sections";
          max_columns = 2;
          sections = [
            {
              title = "Security System";
              cards = [
                {
                  type = "alarm-panel";
                  entity = "alarm_control_panel.home_security";
                  name = "Home Security";
                }
              ];
            }
          ];
        }
        
        # Media Dashboard View (placeholder for future implementation)  
        {
          title = "Media";
          path = "media";
          icon = "mdi:play-circle";
          type = "sections";
          max_columns = 2;
          sections = [
            {
              title = "Media Players";
              cards = [
                {
                  type = "media-control";
                  entity = "media_player.living_room_tv";
                  name = "Living Room TV";
                }
              ];
            }
          ];
        }
      ];
    };
  };
}