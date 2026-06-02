{
  config,
  inputs,
  lib,
  pkgs,
  setup,
  systemConfig,
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
    ../../../shared/user/git.nix
    ../../../shared/user/npm.nix
    ../../../shared/user/direnv.nix
    # ../../../shared/user/ddev.nix
  ];

  # programs.ssh = {
  #   includes = [
  #     "${config.xdg.configHome}/ssh/1password_servers_config"
  #   ];
  # };

  home.packages = [
    pkgs.slack
    pkgs.gh
    pkgs.postman
    pkgs.notion-app
  ];

  programs.git = {
    includes = [
      {
        condition = "gitdir:/Users/work/Documents/Projects/dotfiles/";
        path = "~/.config/git/sushy";
      }
    ];
  };

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
