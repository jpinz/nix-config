{
  lib,
  config,
  ...
}:
let
  cfg = config.programs.oh-my-opencode;

  # Type for an agent configuration
  agentType = lib.types.submodule {
    options = {
      model = lib.mkOption {
        type = lib.types.str;
        description = "The model to use for this agent";
        example = "github-copilot/claude-opus-4.5";
      };
    };
  };
in
{
  options.programs.oh-my-opencode = {
    enable = lib.mkEnableOption "oh-my-opencode configuration";

    agents = {
      sisyphus = lib.mkOption {
        type = lib.types.nullOr agentType;
        default = null;
        description = "Configuration for the sisyphus agent";
        example = {
          model = "github-copilot/claude-opus-4.5";
        };
      };

      oracle = lib.mkOption {
        type = lib.types.nullOr agentType;
        default = null;
        description = "Configuration for the oracle agent";
        example = {
          model = "github-copilot/gpt-5.2";
        };
      };

      explore = lib.mkOption {
        type = lib.types.nullOr agentType;
        default = null;
        description = "Configuration for the explore agent";
        example = {
          model = "opencode/gpt-5-nano";
        };
      };

      librarian = lib.mkOption {
        type = lib.types.nullOr agentType;
        default = null;
        description = "Configuration for the librarian agent";
        example = {
          model = "opencode/big-pickle";
        };
      };
    };

    extraConfig = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Additional configuration to merge into oh-my-opencode.json";
      example = {
        someKey = "someValue";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."opencode/oh-my-opencode.json".text =
      let
        # Filter out null agents
        agents = lib.filterAttrs (_: v: v != null) {
          inherit (cfg.agents)
            sisyphus
            oracle
            explore
            librarian
            ;
        };

        configData = lib.recursiveUpdate { inherit agents; } cfg.extraConfig;
      in
      builtins.toJSON configData;
  };
}
