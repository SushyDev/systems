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
    pkgs.discord
    pkgs.blender
  ];

  programs.zsh = {
    initContent = ''
      # TODO Only if directory exists
      eval "$(fnm env --use-on-cd)"
      # eval "$(/opt/homebrew/bin/brew shellenv)"

      # 1Password plugin needs the completealiases to keep autocomplete working for the aliases it createas for each command
      source $HOME/.config/op/plugins.sh
      setopt completealiases
    '';

    sessionVariables =
      let
        bashList = list: "(${builtins.concatStringsSep " " list})";
      in
      {
        EDITOR = "nvim";
        PROJECTS = bashList [ "$HOME/Documents/Projects" ];
      };
  };
}
