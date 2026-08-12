{
  base,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./darwin.nix
    ../shared/oxidation.nix
  ];

  # nixpkgs.overlays = [ inputs.nix-darwin-apps.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = let
    apps = inputs.nix-darwin-apps.packages.aarch64-darwin;
  in [
    pkgs.opencode
    pkgs.openssh
    pkgs._1password-gui
    pkgs._1password-cli
    pkgs.raycast
    #pkgs.obsidian
    pkgs.opencode
    pkgs.aerospace
    pkgs.spotify
    pkgs.devenv
    pkgs.git-lfs
    pkgs.claude-code
    pkgs.dbeaver-bin
    pkgs.ghostty-bin
    pkgs.orbstack

    # My own overlay
    apps.vivaldi

    # # pkgs.cloudflare-warp-gui
    # # pkgs.google-chrome-canary
    # pkgs.setapp

    inputs.claude-lite.packages.${pkgs.stdenv.hostPlatform.system}.claude-lite
  ];

  fonts.packages = [
    pkgs.fira-code
  ];

  # 1. Enable and configure dnsmasq
  services.dnsmasq = {
    enable = true;

    # Route all *.test requests directly to localhost
    addresses = {
      test = "127.0.0.1";
    };
  };

  # 2. Create the macOS resolver file declaratively
  environment.etc."resolver/localhost".text = ''
    nameserver 127.0.0.1
    port 53
  '';
}
