{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
let
  traits = import ../../modules/traits { inherit lib; };
in
{
  imports = [
    inputs.disko.nixosModules.disko
    inputs.sops-nix.nixosModules.sops
    ./disko/btrfs-raid1.nix
    ./home-manager.nix
    ./bootloader.nix
    ./packages.nix
    ./programs.nix
    ./services.nix
    ./networking.nix
    ./secrets.nix
    ./backups.nix
    ./k3s.nix
    ./k3s-hardening.nix
    ./kubeops.nix
    ./flux.nix
    ./falco.nix

    ./system/default.nix
  ]
  ++ (with traits; [
    # Explicit: the default is every normal user, which would make kubeops a
    # trusted Nix user with write access to this flake -- root by another route.
    (useGroupOwnedFlake {
      gid = 502;
      members = [ "sushy" ];
    })
    useDeterminateNix
    useDirenv
    useHomeManager
    useNixSettings
    useOxidation
    usePasswordlessSudo
  ]);

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
