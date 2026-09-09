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
    ./bootloader.nix
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix
    ./networking.nix
    ./k3s.nix

    ./system/default.nix
    ../shared/oxidation.nix
  ];

  # --- System
  system.stateVersion = "25.05";

  # --- Swap
  #swapDevices = lib.mkForce [];


  nixpkgs.config.allowUnfree = true;

  # --- Shared mount
  # systemd.mounts = [
  #   {
  #     # Bind mount the project directory onto itself to apply rshared
  #     # This is safer than applying it to the whole root filesystem.
  #     where = "/";
  #     what = "none"; # Source and destination are the same
  #     type = "none";
  #     options = "bind,rshared";
  #   }
  # ];
}
