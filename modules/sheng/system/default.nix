{ setup, ... }:
{
  imports = [
    ./nix.nix
    ./users-and-groups.nix
  ];

  # No hardware-configuration.nix or networking.nix: nixos-sheng owns the
  # kernel, device tree, kernel params, rootfs, firmware and bootloader.

  system.activationScripts.setupSystemFlake = {
    text = ''
      mkdir -p ${setup.systemFlakePath}
      chown -R root:nix ${setup.systemFlakePath}
      chmod -R g+rwX ${setup.systemFlakePath}
      chmod -R o+rX ${setup.systemFlakePath}
    '';
  };
}
