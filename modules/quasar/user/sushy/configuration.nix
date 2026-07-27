{
  config,
  inputs,
  lib,
  pkgs,
  setup,
  ...
}:
{
  imports = [
    inputs.nix-plist-manager.homeManagerModules.default
    inputs.dotfiles.homeManagerModules.default
    ../shared/configuration.nix
    ../shared/dotfiles.nix
    ../shared/nix-plist-manager.nix
    ../shared/1password.nix
    ../../../shared/user/direnv.nix
    ../../../shared/user/npm.nix
    ../../../shared/user/git.nix
  ];

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

      # 1Password plugin needs the completealiases to keep autocomplete working for the aliases it createas for each command
      source $HOME/.config/op/plugins.sh
      setopt completealiases
    '';

    sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
