{ pkgs, ... }:
{
  services.hermes-agent = {
    enable = false;
    user = "julian";
    group = "hermes";
    createUser = false;
    addToSystemPackages = true;
    settings = {
      model = {
        provider = "copilot";
        default = "gpt-5.6-luna";
      };
      model_aliases = {
        copilot-gpt = {
          provider = "copilot";
          model = "gpt-5.6-luna";
        };
        local = {
          provider = "custom";
          model = "qwen3:4b";
          base_url = "http://127.0.0.1:11434/v1";
        };
      };
      platform_toolsets.cli = [
        "file"
        "terminal"
        "code_execution"
        "clarify"
        "todo"
      ];
      agent.disabled_toolsets = [
        "vision"
        "image_gen"
        "computer_use"
      ];
      max_turns = 20;
      terminal = {
        backend = "local";
        cwd = "/var/lib/hermes/workspace";
        timeout = 300;
      };
      memory = {
        memory_enabled = true;
        user_profile_enabled = true;
      };
    };
    environment.HERMES_API_TIMEOUT = "1800";
    environmentFiles = [ "/var/lib/hermes/copilot.env" ];
    extraPackages = with pkgs; [
      fd
      gh
      git
      jq
      ripgrep
    ];
  };

  systemd.services.hermes-agent = {
    after = [ "ollama.service" ];
    wants = [ "ollama.service" ];
  };
}