{ setup, ... }:
{
  imports = [
    ./nix.nix
    ./users-and-groups.nix
  ];

  # No hardware-configuration.nix or networking.nix here, unlike pc:
  # nixos-sheng's modules/hardware.nix owns the device tree, kernel,
  # kernel params, root filesystem, firmware and NetworkManager, and
  # modules/extlinux.nix owns the bootloader. Duplicating any of it here
  # would fight those modules rather than extend them.

  system.activationScripts.setupSystemFlake = {
    text = ''
      mkdir -p ${setup.systemFlakePath}
      chown -R root:nix ${setup.systemFlakePath}
      chmod -R g+rwX ${setup.systemFlakePath}
      chmod -R o+rX ${setup.systemFlakePath}
    '';
  };
}
