{
  trait,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (trait.parameters) path group gid;
in
{
  users.groups.${group} = {
    inherit gid;
    members =
      trait.parameters.members
        or (lib.attrNames (lib.filterAttrs (_name: user: user.isNormalUser) config.users.users));
  };

  nix.settings.trusted-users = [
    "root"
    "@${group}"
  ];

  environment.shellAliases.nixos-switch = "${lib.getExe config.system.build.nixos-rebuild} switch --sudo --flake ${path}";

  system.activationScripts.setupSystemFlake.text = import ./setup-script.nix {
    inherit lib pkgs path group;
  };
}
