{ pkgs, ... }:
{
  users.defaultUserShell = pkgs.zsh;

  users.users.sushy = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "docker"
      "i2c"
      "onepassword"
      "kubernetes"
    ];
    uid = 1000;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
    ];
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
    ];
  };
}
