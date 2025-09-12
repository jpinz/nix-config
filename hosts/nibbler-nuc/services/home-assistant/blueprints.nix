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
    ];
  };
}
