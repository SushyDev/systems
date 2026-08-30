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
    ./desktop-manager/kde.nix
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  console.earlySetup = true;
  time.timeZone = "Europe/Amsterdam";

  # No sheng.rootfs.imageSize here. Setting one made resize2fs corrupt the
  # block groups it added, which set the ext4 error flag, which made the
  # kernel refuse growfs -- leaving 16G of a 232G partition. Auto-sized
  # (the default) plus growfs on first boot is what actually works.

  system.stateVersion = "26.11";

  # No networking.hostName here: nixos-sheng's hardware.nix already sets
  # mkDefault "sheng", which is the name we want.
}
