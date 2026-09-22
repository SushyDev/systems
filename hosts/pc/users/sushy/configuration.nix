{
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
    # inputs.plasma-manager.homeModules.plasma-manager
    ../../../../modules/shared/user/git.nix
  ]
  ++ (with traits; [
    useDirenv
    useDotfiles
    useSsh
  ]);

  # plasma = {
  #   enable = true;
  #   workspace.theme = "breeze-dark"; # Or another theme name like "breeze-light"
  #
  #   lookAndFeel.name = "org.kde.breezedark.desktop";
  #   colorScheme.name = "BreezeDark";
  #   iconTheme.name = "breeze-dark";
  #   cursorTheme.name = "breeze_cursors";
  # };

  # programs.zsh = {
  #   profileExtra = lib.mkBefore ''
  #     if [ -z "$KDE_FULL_SESSION" ] && [ "$XDG_SESSION_TYPE" = "tty" ]; then
  #       exec startplasma-wayland
  #     fi
  #   '';
  # };

  home.packages = [
    pkgs.mpv
  ];

  # The state version is required and should stay at the version you
  # originally installed
  home.stateVersion = "25.05";
}
