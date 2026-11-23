{ ... }:
{
  imports = [
    ./nix.nix
    ./networking.nix
    ./remote-builder.nix
    ./users-and-groups.nix

    ./hardware-configuration.nix
    ./additional-hardware-configuration.nix
  ];
}
