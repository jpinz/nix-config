{ pkgs, ... }:
{
  services.home-assistant.blueprints = {
    automation = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/rohankapoorcom/homeassistant-config/refs/heads/master/blueprints/automation/rohankapoorcom/inovelli-vzm31-sn-blue-series-switch.yaml";
        hash = "sha256-oc268sq0/KXO6NEQubrwKTGCFpe5H6Onx++dwcxjeEQ=";
      })
    ];
    script = [
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/kschlichter/Home-Assistant-Inovelli-Effects-and-Colors/refs/heads/master/blueprints/script/kschlichter/inovelli_led_blueprint.yaml";
        hash = "sha256-cc6+l2l7csqg+H1MJK81UvqHK9WDoEfqQ45mddKFEvg=";
      })
      (pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/zanix/home-assistant-blueprints/b6c34f8df8c161bc04be9f4999151d4fc5bb8996/script/inovelli_blue_led_zigbee2mqtt.yaml";
        hash = "sha256-7YuWw1puZxWn5jMhFK8z3rLlJGc5VsO0/iLROs7MUQc=";
      })
    ];
  };
}
