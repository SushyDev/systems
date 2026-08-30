{
  setup,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix

    ./system/default.nix
    ../shared/oxidation.nix
    ../shared/fonts.nix
    ./desktop-manager
  ];

  networking.hostName = "sheng";

  i18n.defaultLocale = "en_US.UTF-8";
  console.earlySetup = true;
  time.timeZone = "Europe/Amsterdam";

  # The touch shell, offered beside the desktop one in the U-Boot menu.
  # inheritParentConfig defaults to true, so everything else -- firmware,
  # users, home-manager, the package set -- comes through unchanged.
  specialisation.plasma-mobile.configuration = {
    sheng.desktop.shell = "plasma-mobile";
  };

  # No sheng.rootfs.imageSize: a fixed size corrupts the block groups resize2fs
  # adds, which then blocks growfs too.

  system.stateVersion = "26.11";
}
