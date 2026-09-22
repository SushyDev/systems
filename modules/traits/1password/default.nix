{
  config,
  lib,
  options,
  ...
}:
let
  hasPolkit = options.programs._1password-gui ? polkitPolicyOwners;
  isDarwin = options ? launchd;
in
{
  config = lib.mkMerge [
    {
      programs._1password.enable = true;
      programs._1password-gui.enable = true;

      home-manager.sharedModules = [ ./home.nix ];
    }

    (lib.optionalAttrs hasPolkit {
      programs._1password-gui.polkitPolicyOwners = lib.mkDefault (
        lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users)
      );
    })

    (lib.optionalAttrs isDarwin {
      # Older generations symlinked this into the store, which rsync can't write through.
      system.activationScripts.applications.text = lib.mkBefore ''
        if [ -L /Applications/1Password.app ]; then
          rm /Applications/1Password.app
        fi
      '';
    })
  ];
}
