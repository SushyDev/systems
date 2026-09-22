{ ... }:
{
  imports = [
    ./nix.nix
    ./users-and-groups.nix
  ];

  # No hardware-configuration.nix or networking.nix: nixos-sheng owns the
  # kernel, device tree, kernel params, rootfs, firmware and bootloader.
}
