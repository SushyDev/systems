{
  trait,
  lib,
  pkgs,
  ...
}:
{
  environment.shellAliases."${trait.class}-update" =
    "${lib.getExe pkgs.nix} flake update --flake ${trait.parameters.path}";
}
