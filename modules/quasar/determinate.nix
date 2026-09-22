{ setup, ... }:
{
  determinateNix = {
    enable = true;

    customSettings = {
      experimental-features = [ "external-builders" ];
      trusted-users = setup.managedUsersAndRoot;
      lazy-trees = true;
      max-jobs = 14;
      extra-substituters = [ "https://claude-code.cachix.org" ];
      extra-trusted-public-keys = [
        "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
      ];
      # external-builders = builtins.toJSON [
      #   {
      #     systems = [ "x86_64-linux" "aarch64-linux" ];
      #     program = "/usr/local/bin/darwin-nixd";
      #     args = [ "builder" ];
      #   }
      # ];
    };

    determinateNixd.builder.cpuCount = 15;
  };
}
