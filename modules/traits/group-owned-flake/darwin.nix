{
  trait,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (trait.parameters) path group gid;
  trustedUsers = [
    "root"
    "@${group}"
  ];
in
{
  config = lib.mkMerge [
    {
      users.knownGroups = [ group ];
      users.groups.${group} = {
        inherit gid;
        members = trait.parameters.members or config.users.knownUsers;
      };

      environment.shellAliases.darwin-switch = "sudo ${lib.getExe pkgs.nix} run nix-darwin/master#darwin-rebuild -- switch --show-trace --flake ${path}";

      system.activationScripts.extraActivation.text = lib.mkAfter (
        import ./setup-script.nix { inherit lib pkgs path group; }
      );
    }

    (
      if trait.capabilities.determinateNix then
        { determinateNix.customSettings.trusted-users = trustedUsers; }
      else
        { nix.settings.trusted-users = trustedUsers; }
    )
  ];
}
