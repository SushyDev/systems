{
  self,
  lib,
  setup,
  ...
}:
{
  system.defaults = {
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    NSGlobalDomain = {
      AppleSpacesSwitchOnActivate = true; # todo nix plist manager
      NSNavPanelExpandedStateForSaveMode = true; # todo nix plist manager
      NSNavPanelExpandedStateForSaveMode2 = true; # todo nix plist manager
      AppleICUForce24HourTime = true; # todo nix plist manager
      AppleShowAllExtensions = true; # todo nix plist manager
      ApplePressAndHoldEnabled = false; # todo nix plist manager
      "com.apple.springing.delay" = 0.5; # todo nix plist manager
      "com.apple.springing.enabled" = true; # todo nix plist manager
    };

    CustomUserPreferences = lib.attrsets.mergeAttrsList (
      lib.map (user: {
        "~${user}/Library/Preferences/ByHost/.GlobalPreferences" = {
          "AppleMiniaturizeOnDoubleClick" = 0; # todo nix plist manager
        };
        "~${user}/Library/Preferences/ByHost/com.apple.assistant.support" = {
          # I assume this turns off Siri Data collection just like with Spotlight above
          "Siri Data Sharing Opt-In Status" = 2; # todo nix plist manager
        };
      }) setup.managedUsers
    );
  };
}
