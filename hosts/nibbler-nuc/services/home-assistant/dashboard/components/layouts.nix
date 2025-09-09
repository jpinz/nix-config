{ lib, ... }:
let
  inherit (lib) mkDefault;
in
{
  # Responsive layout components for mobile and desktop
  
  # Mobile-optimized layout with single column
  mobileLayout = { sections ? [] }: {
    type = "sections";
    max_columns = 1;
    card_mod = {
      style = ''
        @media (max-width: 768px) {
          .sections {
            gap: var(--spacing-sm, 8px) !important;
            padding: var(--spacing-sm, 8px) !important;
          }
          
          .section .cards {
            gap: var(--spacing-xs, 4px) !important;
          }
          
          ha-card {
            margin: var(--spacing-xs, 4px) 0 !important;
          }
        }
      '';
    };
    sections = sections;
  };
  
  # Desktop-optimized layout with multiple columns
  desktopLayout = { sections ? [], maxColumns ? 3 }: {
    type = "sections";
    max_columns = maxColumns;
    card_mod = {
      style = ''
        @media (min-width: 769px) {
          .sections {
            gap: var(--spacing-lg, 16px) !important;
            padding: var(--spacing-lg, 16px) !important;
          }
          
          .section {
            min-width: 300px;
          }
          
          .section .cards {
            gap: var(--spacing-md, 12px) !important;
          }
          
          ha-card {
            margin: var(--spacing-sm, 8px) 0 !important;
          }
        }
      '';
    };
    sections = sections;
  };
  
  # Adaptive layout that switches between mobile and desktop
  adaptiveLayout = { sections ? [], mobileColumns ? 1, desktopColumns ? 3 }: {
    type = "sections";
    max_columns = desktopColumns;
    card_mod = {
      style = ''
        .sections {
          gap: var(--spacing-lg, 16px);
          padding: var(--spacing-lg, 16px);
          transition: all 0.3s ease;
        }
        
        .section {
          transition: all 0.3s ease;
        }
        
        .section .cards {
          gap: var(--spacing-md, 12px);
          transition: all 0.3s ease;
        }
        
        ha-card {
          margin: var(--spacing-sm, 8px) 0;
          transition: all 0.3s ease;
        }
        
        /* Mobile styles */
        @media (max-width: 768px) {
          :host {
            --sections-max-columns: ${toString mobileColumns} !important;
          }
          
          .sections {
            gap: var(--spacing-sm, 8px) !important;
            padding: var(--spacing-sm, 8px) !important;
          }
          
          .section .cards {
            gap: var(--spacing-xs, 4px) !important;
          }
          
          ha-card {
            margin: var(--spacing-xs, 4px) 0 !important;
          }
        }
        
        /* Tablet styles */
        @media (min-width: 769px) and (max-width: 1024px) {
          :host {
            --sections-max-columns: ${toString (if desktopColumns > 2 then 2 else desktopColumns)} !important;
          }
        }
        
        /* Desktop styles */
        @media (min-width: 1025px) {
          :host {
            --sections-max-columns: ${toString desktopColumns} !important;
          }
          
          .section {
            min-width: 320px;
          }
        }
      '';
    };
    sections = sections;
  };
  
  # Grid layout for cards
  gridLayout = { cards, columns ? 2, gap ? "12px" }: {
    type = "grid";
    columns = columns;
    square = false;
    cards = cards;
    card_mod = {
      style = ''
        .grid {
          gap: ${gap} !important;
          transition: gap 0.3s ease;
        }
        
        @media (max-width: 768px) {
          .grid {
            grid-template-columns: 1fr !important;
            gap: var(--spacing-xs, 4px) !important;
          }
        }
        
        @media (min-width: 769px) and (max-width: 1024px) {
          .grid {
            grid-template-columns: repeat(${toString (if columns > 2 then 2 else columns)}, 1fr) !important;
            gap: var(--spacing-sm, 8px) !important;
          }
        }
      '';
    };
  };
  
  # Horizontal stack with responsive behavior
  horizontalStack = { cards }: {
    type = "horizontal-stack";
    cards = cards;
    card_mod = {
      style = ''
        .card-content {
          display: flex;
          gap: var(--spacing-md, 12px);
          transition: all 0.3s ease;
        }
        
        .card-content > * {
          flex: 1;
          min-width: 0;
        }
        
        @media (max-width: 768px) {
          .card-content {
            flex-direction: column;
            gap: var(--spacing-xs, 4px) !important;
          }
          
          .card-content > * {
            flex: none;
            width: 100%;
          }
        }
      '';
    };
  };
  
  # Vertical stack with consistent spacing
  verticalStack = { cards }: {
    type = "vertical-stack";
    cards = cards;
    card_mod = {
      style = ''
        .card-content {
          gap: var(--spacing-md, 12px);
        }
        
        .card-content > * {
          margin: 0 0 var(--spacing-md, 12px) 0;
        }
        
        .card-content > *:last-child {
          margin-bottom: 0;
        }
        
        @media (max-width: 768px) {
          .card-content {
            gap: var(--spacing-xs, 4px);
          }
          
          .card-content > * {
            margin: 0 0 var(--spacing-xs, 4px) 0;
          }
        }
      '';
    };
  };
  
  # Masonry layout for dynamic height cards
  masonryLayout = { cards }: {
    type = "masonry";
    cards = cards;
    card_mod = {
      style = ''
        .masonry {
          column-gap: var(--spacing-lg, 16px);
          column-count: 3;
          transition: all 0.3s ease;
        }
        
        .masonry > * {
          break-inside: avoid;
          margin-bottom: var(--spacing-lg, 16px);
        }
        
        @media (max-width: 768px) {
          .masonry {
            column-count: 1 !important;
            column-gap: 0 !important;
          }
          
          .masonry > * {
            margin-bottom: var(--spacing-sm, 8px) !important;
          }
        }
        
        @media (min-width: 769px) and (max-width: 1024px) {
          .masonry {
            column-count: 2 !important;
            column-gap: var(--spacing-md, 12px) !important;
          }
        }
      '';
    };
  };
  
  # Section container with material design styling
  materialSection = { title, cards ? [], icon ? null, collapsible ? false }: {
    title = title;
    cards = cards;
    card_mod = {
      style = ''
        .section-header {
          color: var(--primary-text-color);
          font-weight: 500;
          font-size: 1.1em;
          padding: var(--spacing-md, 12px) 0 var(--spacing-sm, 8px) 0;
          border-bottom: 1px solid var(--divider-color);
          margin-bottom: var(--spacing-md, 12px);
        }
        
        .section-content {
          display: flex;
          flex-direction: column;
          gap: var(--spacing-md, 12px);
        }
        
        @media (max-width: 768px) {
          .section-header {
            font-size: 1em;
            padding: var(--spacing-sm, 8px) 0 var(--spacing-xs, 4px) 0;
            margin-bottom: var(--spacing-sm, 8px);
          }
          
          .section-content {
            gap: var(--spacing-xs, 4px);
          }
        }
      '';
    };
  } // lib.optionalAttrs (icon != null) {
    icon = icon;
  } // lib.optionalAttrs collapsible {
    collapsible = true;
  };
}