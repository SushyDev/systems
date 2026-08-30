{
  inputs,
  lib,
  pkgs,
  setup,
  ...
}:
{
  imports = [
    inputs.dotfiles.homeManagerModules.default
    inputs.plasma-manager.homeModules.plasma-manager
    # Three levels, not two: this file is modules/sheng/users/sushy/, and
    # the shared tree is modules/shared/. pc/users/sushy/configuration.nix
    # uses ../../ here, which resolves to modules/pc/shared/ and does not
    # exist -- worth fixing there too.
    ../../../shared/user/ssh.nix
  ];

  dotfiles = {
    enable = true;
    systemFlakePath = setup.systemFlakePath;
  };

  # Plasma settings that are hardware facts on a tablet, managed here so
  # they survive a reinstall rather than being clicked in once.
  #
  # overrideConfig stays false (the default): only the keys named below
  # are written, and everything else set through the GUI is left alone.
  programs.plasma = {
    enable = true;

    # KWin picks the on-screen keyboard by the .desktop file of an input
    # method, and defaults to none -- so a tablet with no hardware
    # keyboard has no way to type. maliit-keyboard is installed by
    # modules/sheng/desktop-manager/kde.nix; this is what actually
    # selects it.
    configFile.kwinrc.Wayland = {
      InputMethod.value =
        "${pkgs.maliit-keyboard}/share/applications/com.github.maliit.keyboard.desktop";
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

  home.packages = [
    # pc has pkgs.mpv here; it has no aarch64-linux build, so this list is
    # empty rather than carrying a package that will not evaluate.
  ];

  home.stateVersion = "26.11";
}
