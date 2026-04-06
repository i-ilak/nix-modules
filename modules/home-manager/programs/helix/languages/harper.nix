{
  pkgs,
  ...
}:
{
  programs.helix = {
    extraPackages = with pkgs; [ harper ];
    languages = {
      language-server = {
        "harper-ls" = {
          command = "harper-ls";
          args = [ "--stdio" ];
          config.harper-ls = {
            diagnosticSeverity = "error";
            linters = {
              long_sentences = false;
            };
          };
        };
      };
      default = {
        language-servers = [ "harper-ls" ];
      };
    };
  };
}
