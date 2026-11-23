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
    inputs.plasma-manager.homeModules.plasma-manager
    ../../../../modules/shared/user/git.nix
  ]
  ++ (with traits; [
    useDirenv
    useDotfiles
    useSsh
  ]);

  programs.plasma = {
    enable = true;

    # KWin picks the on-screen keyboard by .desktop file and defaults to none.
    configFile.kwinrc.Wayland = {
      InputMethod.value = "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";
      VirtualKeyboardEnabled.value = true;
    };

    # The indexer's extractor alone held ~1.3G PSS on this device.
    configFile.baloofilerc."Basic Settings".Indexing-Enabled.value = false;
  };

  home.stateVersion = "26.11";
}
