{
  trait,
  config,
  lib,
  ...
}:
let
  browserExecutables = {
    google-chrome = "chrome";
    vivaldi = "vivaldi-bin";
  };

  userPackages = lib.optionals trait.capabilities.homeManager (
    lib.concatMap (user: user.home.packages) (lib.attrValues config.home-manager.users)
  );

  allowedBrowsers = lib.unique (
    lib.concatMap (
      package: lib.optional (browserExecutables ? ${lib.getName package}) browserExecutables.${lib.getName package}
    ) (config.environment.systemPackages ++ userPackages)
  );
in
{
  programs._1password-gui.polkitPolicyOwners = lib.mkDefault (
    lib.attrNames (lib.filterAttrs (_name: user: user.isNormalUser) config.users.users)
  );

  environment.etc."1password/custom_allowed_browsers" = lib.mkIf (allowedBrowsers != [ ]) {
    text = lib.concatStringsSep "\n" allowedBrowsers;
    mode = "0755";
  };
}
