# Modular Home Assistant Dashboard

A comprehensive, modular Home Assistant dashboard system built with Material Design 3 principles, responsive layouts, and reusable components using card-mod and bubble-card.

## Features

- 🎨 **Material Design 3** - Full implementation of Material Design 3 color system, typography, and elevation
- 📱 **Responsive Design** - Optimized layouts for mobile, tablet, and desktop
- 🧩 **Modular Components** - Reusable card components and layout functions 
- 🌓 **Light/Dark Themes** - Complete light and dark theme variants
- 🏠 **Multiple Views** - Dedicated views for home, lights, climate, security, and media
- ⚡ **Modern Cards** - Utilizes bubble-card and card-mod for advanced styling
- 🎯 **Accessibility** - Proper contrast ratios and touch targets

## Architecture

```
dashboard/
├── components/          # Reusable component functions
│   ├── cards.nix       # Card component library
│   └── layouts.nix     # Layout and responsive helpers
├── themes/             # Theme configurations
│   └── material-design.nix
├── views/              # Dashboard view definitions
│   ├── home.nix        # Main dashboard view
│   ├── lights.nix      # Lighting controls view
│   └── ...             # Additional views
├── default.nix         # Main dashboard configuration
└── README.md          # This documentation
```

## Component Library

### Cards (`components/cards.nix`)

#### `materialButtonCard`
A Material Design button card with hover effects and customizable styling.

```nix
materialButtonCard {
  entity = "light.living_room";
  name = "Living Room";
  icon = "mdi:lightbulb";
  color = "var(--primary-color)";
  size = "40px";
  showState = true;
}
```

#### `materialLightCard`
A sophisticated light control card with brightness, color, and color temperature controls.

```nix
materialLightCard {
  entity = "light.kitchen";
  name = "Kitchen";
  showBrightness = true;
  showColorTemp = true;
  showColor = true;
}
```

#### `materialSensorCard`
A clean sensor display card with proper Material Design styling.

```nix
materialSensorCard {
  entity = "sensor.temperature";
  name = "Temperature";
  icon = "mdi:thermometer";
  unit = "°C";
}
```

#### `materialWeatherCard`
A comprehensive weather card with forecast display.

```nix
materialWeatherCard {
  entity = "weather.forecast_home";
}
```

### Layouts (`components/layouts.nix`)

#### `adaptiveLayout`
Responsive layout that adapts column count based on screen size.

```nix
adaptiveLayout {
  sections = [ /* section definitions */ ];
  mobileColumns = 1;
  desktopColumns = 3;
}
```

#### `gridLayout`
Responsive grid layout for card arrangements.

```nix
gridLayout {
  cards = [ /* card definitions */ ];
  columns = 2;
  gap = "12px";
}
```

#### `materialSection`
Styled section container with Material Design appearance.

```nix
materialSection {
  title = "Quick Controls";
  cards = [ /* cards */ ];
  icon = "mdi:lightning-bolt";
}
```

## Themes

### Material Light Theme
- Primary Color: `#6750A4` (Material Purple)
- Background: `#FFFBFE` (Material Surface)
- Cards: Elevated with proper shadows
- Typography: Roboto font family

### Material Dark Theme
- Primary Color: `#D0BCFF` (Material Purple Dark)
- Background: `#141218` (Material Dark Surface)
- Cards: Dark elevated appearance
- Proper dark mode contrast ratios

## Views

### Home View (`views/home.nix`)
The main dashboard providing an overview of all systems:
- Quick Controls section with lights and climate
- Weather & Environment monitoring
- Energy & Utilities tracking
- Device Status overview

### Lights View (`views/lights.nix`)
Comprehensive lighting control interface:
- Room-by-room light controls
- Outdoor lighting section
- Light group management
- Lighting scenes (Morning, Evening, Night, etc.)
- Adaptive lighting controls

### Future Views
- Climate: Temperature, humidity, and HVAC controls
- Security: Alarm panel, cameras, door locks
- Media: Media players, speakers, TV controls

## Responsive Behavior

### Mobile (≤768px)
- Single column layout
- Larger touch targets
- Simplified navigation
- Bottom navigation bar

### Tablet (769px - 1024px)
- 2-column layout where applicable
- Medium spacing
- Hover effects enabled

### Desktop (≥1025px)
- 3-column layout (configurable)
- Full hover and animation effects
- Larger spacing for better visual hierarchy

## Custom CSS Features

### Material Design Implementation
- Complete MD3 color token system
- Proper elevation shadows
- Material typography scale
- Responsive breakpoints
- Smooth transitions and animations

### Interactive Elements
- Hover effects with proper elevation changes
- Loading animations
- State-based styling
- Focus indicators for accessibility

## Usage

### Adding New Cards
1. Define reusable card functions in `components/cards.nix`
2. Use the card functions in view definitions
3. Apply consistent Material Design styling

### Creating New Views
1. Create a new view file in `views/`
2. Import required components and layouts
3. Define sections with cards
4. Add responsive styling
5. Import the view in `default.nix`

### Customizing Themes
1. Modify color tokens in `themes/material-design.nix`
2. Update both light and dark variants
3. Rebuild Home Assistant configuration

## Dependencies

Required Home Assistant custom components:
- `bubble-card` - Modern card designs
- `card-mod` - Advanced CSS styling
- `button-card` - Customizable buttons
- `mushroom` - Clean card designs
- `mini-graph-card` - Data visualization
- `universal-remote-card` - Media controls

## Installation

The dashboard is automatically configured when the Home Assistant service is enabled. The modular structure allows for easy customization and extension.

```bash
# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake .#nibbler-nuc
```

## Contributing

When adding new components:
1. Follow Material Design 3 guidelines
2. Ensure responsive behavior
3. Use consistent naming conventions
4. Document component parameters
5. Test on mobile and desktop