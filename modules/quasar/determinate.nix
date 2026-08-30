{
  self,
  nixpkgs,
  determinateNix,
  setup,
  ...
}:
{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
        "auto-allocate-uids"
      ];
      auto-optimise-store = true;
      max-jobs = 14;
      cores = 0; # Use all cores
      keep-outputs = true;
      keep-derivations = true;
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      download-buffer-size = 2147483648;
    };
  };

  determinateNix = {
    enable = true;

    customSettings = {
      experimental-features = "nix-command flakes external-builders";
      trusted-users = setup.managedUsersAndRoot;
      lazy-trees = true;
      # external-builders = builtins.toJSON [
      #   {
      #     systems = [ "x86_64-linux" "aarch64-linux" ];
      #     program = "/usr/local/bin/darwin-nixd";
      #     args = [ "builder" ];
      #   }
      # ];
    };

    determinateNixd = {
      garbageCollector.strategy = "automatic";
      builder.cpuCount = 15;
    };
  };
}
