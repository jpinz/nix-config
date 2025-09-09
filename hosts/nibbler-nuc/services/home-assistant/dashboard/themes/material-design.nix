{ ... }:
{
  # Material Design Theme Configuration
  materialTheme = {
    # Main colors based on Material Design 3
    primary-color = "#6750A4";
    accent-color = "#625B71";
    dark-primary-color = "#D0BCFF";
    light-primary-color = "#EADDFF";
    
    # Background colors
    primary-background-color = "#FFFBFE";
    secondary-background-color = "#F7F2FA";
    card-background-color = "#FFFFFF";
    
    # Dark mode colors
    primary-background-color-dark = "#141218";
    secondary-background-color-dark = "#211F26";
    card-background-color-dark = "#2B2930";
    
    # Text colors
    primary-text-color = "#1C1B1F";
    secondary-text-color = "#49454F";
    disabled-text-color = "#C7C5CA";
    
    # Dark mode text colors  
    primary-text-color-dark = "#E6E1E5";
    secondary-text-color-dark = "#CAC4D0";
    disabled-text-color-dark = "#938F96";
    
    # Border and divider colors
    divider-color = "#79747E";
    outline-color = "#79747E";
    
    # State colors
    state-icon-color = "#49454F";
    state-icon-active-color = "#6750A4";
    state-icon-unavailable-color = "#C7C5CA";
    
    # Sidebar
    sidebar-background-color = "#F7F2FA";
    sidebar-text-color = "#1C1B1F";
    sidebar-selected-background-color = "#EADDFF";
    sidebar-selected-text-color = "#21005D";
    
    # Switch colors
    switch-checked-button-color = "#FFFFFF";
    switch-checked-track-color = "#6750A4";
    switch-unchecked-button-color = "#938F96";
    switch-unchecked-track-color = "#E7E0EC";
    
    # Slider colors
    slider-color = "#6750A4";
    slider-track-color = "#E7E0EC";
    
    # Success/Error/Warning colors
    success-color = "#146C2E";
    error-color = "#BA1A1A";
    warning-color = "#A08100";
    info-color = "#0061A4";
    
    # Card shadows and elevation
    ha-card-box-shadow = "0px 1px 2px 0px rgba(0, 0, 0, 0.3), 0px 1px 3px 1px rgba(0, 0, 0, 0.15)";
    ha-card-border-radius = "12px";
    
    # Material Design spacing
    spacing-xs = "4px";
    spacing-sm = "8px";  
    spacing-md = "12px";
    spacing-lg = "16px";
    spacing-xl = "24px";
    spacing-xxl = "32px";
  };
  
  # Dark theme variant
  materialThemeDark = {
    # Inherit from light theme and override specific colors
    primary-color = "#D0BCFF";
    accent-color = "#CCC2DC";
    
    primary-background-color = "#141218";
    secondary-background-color = "#211F26";
    card-background-color = "#2B2930";
    
    primary-text-color = "#E6E1E5";
    secondary-text-color = "#CAC4D0"; 
    disabled-text-color = "#938F96";
    
    divider-color = "#938F96";
    outline-color = "#938F96";
    
    state-icon-color = "#CAC4D0";
    state-icon-active-color = "#D0BCFF";
    state-icon-unavailable-color = "#938F96";
    
    sidebar-background-color = "#211F26";
    sidebar-text-color = "#E6E1E5";
    sidebar-selected-background-color = "#4F378B";
    sidebar-selected-text-color = "#EADDFF";
    
    switch-checked-button-color = "#381E72";
    switch-checked-track-color = "#D0BCFF";
    switch-unchecked-button-color = "#938F96";
    switch-unchecked-track-color = "#4A4458";
    
    slider-color = "#D0BCFF";
    slider-track-color = "#4A4458";
    
    success-color = "#4F7942";
    error-color = "#F2B8B5";
    warning-color = "#E6C500";
    info-color = "#5DADE2";
    
    ha-card-box-shadow = "0px 1px 2px 0px rgba(0, 0, 0, 0.6), 0px 1px 3px 1px rgba(0, 0, 0, 0.3)";
    ha-card-border-radius = "12px";
  };
}