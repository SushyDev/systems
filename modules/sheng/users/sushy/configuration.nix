{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  traits = import ../../../traits { inherit lib; };
in
{
  imports = [
    inputs.plasma-manager.homeModules.plasma-manager
  ]
  ++ (with traits; [
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
  };

  programs.git = {
    settings.user.name = "SushyDev";
    settings.user.email = "mail@sushy.dev";
    signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImyhNk+raDf5TXHFWOyWIKw8IQapkhwJ5e+iLQydSFR";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.stateVersion = "26.11";
}
