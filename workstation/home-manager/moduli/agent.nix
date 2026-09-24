{ config, lib, pkgs, ... }:

{
  programs.pi-coding-agent = {
    enable = true;
    models = {
      providers = {
        openrouter = {
          api = "openai-completions";
          apiKey = "sk-or-v1-tua-api-openrouter"; # Inserisci qui la tua chiave di OpenRouter
          baseUrl = "https://openrouter.ai/api/v1";
          models = [
            {
              id = "openrouter/free"; # Router automatico per i modelli gratuiti
            }
            {
              id = "xiaomi/mimo-v2.5";
            }
            {
              id = "cohere/north-mini-code:free";
            }
          ];
        };
      };
    };
  };
}
