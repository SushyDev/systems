{
  setup,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  traits = import ../traits;
in
{
  imports = [
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix

    ./system/default.nix
    ../shared/fonts.nix
    ./desktop-manager/kde.nix
  ]
  ++ (with traits; [
    (useGroupOwnedFlake {
      path = setup.systemFlakePath;
      gid = setup.nixGroupId;
      members = setup.nixGroupMembers;
      group = setup.nixGroupName;
    })
    useNixSettings
    use1Password
    useKde
    useOxidation
    usePasswordlessSudo
  ]);

  networking.hostName = "sheng";

  i18n.defaultLocale = "en_US.UTF-8";
  console.earlySetup = true;
  time.timeZone = "Europe/Amsterdam";

  # Mutable copy of this flake at /etc/nixos in the image, so the tablet
  # rebuilds from the config it was flashed with.
  sheng.rootfs.etcNixosSource = inputs.self;

  # Qt Multimedia via GStreamer; without it Qt apps report "no camera detected".
  sheng.camera.qtGstreamerBackend = true;

  # No sheng.rootfs.imageSize: a fixed size corrupts the block groups resize2fs
  # adds, which then blocks growfs too.

  system.stateVersion = "26.11";
}
