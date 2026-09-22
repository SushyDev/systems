{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  traits = import ../../../../modules/traits { inherit lib; };
in
{
  imports = [
    inputs.nix-plist-manager.homeManagerModules.default
    ../shared/configuration.nix
    ../shared/nix-plist-manager.nix
    ../../../../modules/shared/user/git.nix
  ]
  ++ (with traits; [
    useDirenv
    useDotfiles
    useNpm
    useSsh
  ]);

  home.packages = [
    #pkgs.discord-ptb
    #pkgs.blender
    pkgs.docker-compose
  ];

  home.file = {
    ".config/opencode/opencode.jsonc" = {
      text = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "mcp": {
            "nix": {
              "type": "local",
              "command": ["nix", "run", "github:utensils/mcp-nixos", "--"],
              "enabled": true
            }
          }
        }
      '';
      force = true;
    };

    ".docker/cli-plugins/docker-compose" = {
      source = "${pkgs.docker-compose}/bin/docker-compose";
      force = true;
    };
  };

  programs.zsh = {
    initContent = ''
      PROJECTS=(${builtins.concatStringsSep " " [ "$HOME/Documents/Projects" ]})

      # TODO Only if directory exists
      eval "$(fnm env --use-on-cd)"
      # eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
