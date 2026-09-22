{
  path,
  gid,
  members,
  group ? "nix",
}:
{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  isDarwin = options ? launchd;
  nix = lib.getExe pkgs.nix;
  prefix = if isDarwin then "darwin" else "nixos";
  coreutil = lib.getExe' pkgs.coreutils;
  setupFlake = ''
    ${coreutil "mkdir"} -p ${path}
    ${coreutil "chown"} -R root:${group} ${path}
    ${coreutil "chmod"} -R g+rwX,o+rX ${path}
  '';
in
{
  key = "traits/group-owned-flake";

  config = lib.mkMerge [
    {
      users.groups.${group} = { inherit gid members; };

      environment.shellAliases."${prefix}-update" = "${nix} flake update --flake ${path}";

      home-manager.sharedModules = [ { programs.git.settings.safe.directory = path; } ];
    }

    (lib.optionalAttrs isDarwin {
      users.knownGroups = [ group ];

      environment.shellAliases.darwin-switch = "sudo ${nix} run nix-darwin/master#darwin-rebuild -- switch --show-trace --flake ${path}";

      system.activationScripts.extraActivation.text = lib.mkAfter setupFlake;
    })

    (lib.optionalAttrs (!isDarwin) {
      environment.shellAliases.nixos-switch = "${lib.getExe config.system.build.nixos-rebuild} switch --sudo --flake ${path}";

      system.activationScripts.setupSystemFlake.text = setupFlake;
    })
  ];
}
