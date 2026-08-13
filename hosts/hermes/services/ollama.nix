{ ... }:
{
  services.ollama = {
    enable = false;
    host = "127.0.0.1";
    port = 11434;
    openFirewall = false;
    loadModels = [ "qwen3:4b" ];
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "65536";
      OLLAMA_KEEP_ALIVE = "15m";
      OLLAMA_NUM_PARALLEL = "1";
    };
  };
}