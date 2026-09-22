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
    # useDdev
  ]);

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
    pkgs.google-chrome
    pkgs.librewolf
    pkgs.acli
    pkgs.antigravity-cli
    pkgs.fnm
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
  };

  programs.git = {
    lfs.enable = true;

    includes = [
      {
        condition = "gitdir:/Users/work/Documents/Projects/dotfiles/";
        path = "~/.config/git/sushy";
      }
    ];
  };

  programs.zsh = {
    initContent = ''
      PROJECTS=(${builtins.concatStringsSep " " [ "$HOME/Documents/Projects" ]})

      # TODO Only if directory exists
      eval "$(fnm env --use-on-cd --shell zsh)"
      # eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    sessionVariables = {
      EDITOR = "nvim";
    };
  };
}
