{ pkgs, ... }:
{
  services.home-assistant = {
    lovelaceConfig = {
      button_card_templates = {
        room_card = {
          variables = {
            name = "Name";
            icon = "mdi:unicorn";
            path = "#path";
            state = null;
            background = "var(--bubble-main-background-color)";
            color = "var(--bubble-accent-color)";
            text = "var(--input-ink-color)";
            radius = "36px 36px 36px 6px";
          };
          icon = "[[[ return variables.icon ]]]";
          name = "[[[ return variables.name ]]]";
          tap_action = {
            action = "navigate";
            navigation_path = "[[[ return variables.path ]]]";
          };
          custom_fields = {
            temp = "[[[ return variables.state ]]]";
          };
          styles = {
            card = [
              { padding = "8px"; }
              { height = "100%"; }
              { "border-radius" = "[[[ return variables.radius ]]]"; }
              { background = "[[[ return variables.background ]]]"; }
            ];
            grid = [
              { "grid-template-areas" = "\"n i\" \"temp temp\""; }
              { "grid-template-rows" = "1fr min-content"; }
              { "grid-template-columns" = "min-content 1fr"; }
            ];
            icon = [
              { width = "28px"; }
              { color = "var(--black)"; }
            ];
            img_cell = [
              { "justify-self" = "end"; }
              { background = "[[[ return variables.color ]]]"; }
              { "border-radius" = "100%"; }
              { "align-self" = "start"; }
              { width = "60px"; }
              { height = "60px"; }
            ];
            name = [
              { "justify-self" = "start"; }
              { "align-self" = "start"; }
              { "text-align" = "left"; }
              { "font-size" = "1em"; }
              { "font-weight" = 500; }
              { color = "[[[ return variables.text ]]]"; }
              { padding = "14px"; }
            ];
            custom_fields = {
              temp = [
                { "justify-self" = "start"; }
                { "font-size" = "3em"; }
                { "line-height" = "1em"; }
                { "font-weight" = 300; }
                { color = "[[[ return variables.text ]]]"; }
                { padding = "0 0 6px 14px"; }
              ];
            };
          };
        };
      };
    };
  };
}
