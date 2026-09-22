{
  base,
  inputs,
  pkgs,
  setup,
  ...
}:
let
  traits = import ../traits;
in
{
  imports = [
    ./darwin.nix
  ]
  ++ (with traits; [
    (useGroupOwnedFlake {
      path = setup.systemFlakePath;
      gid = setup.nixGroupId;
      members = setup.nixGroupMembers;
      group = setup.nixGroupName;
    })
    useNixSettings
    use1Password
    useOxidation
  ]);

  # nixpkgs.overlays = [ inputs.nix-darwin-apps.overlays.default ];
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = let
    apps = inputs.nix-darwin-apps.packages.aarch64-darwin;
  in [
    pkgs.opencode
    pkgs.openssh
    pkgs.raycast
    #pkgs.obsidian
    pkgs.opencode
    pkgs.aerospace
    pkgs.spotify
    pkgs.devenv
    pkgs.git-lfs
    pkgs.claude-code # from inputs.claude-code overlay
    pkgs.dbeaver-bin
    pkgs.ghostty-bin
    pkgs.orbstack

    # My own overlay
    apps.vivaldi

    # # pkgs.cloudflare-warp-gui
    # # pkgs.google-chrome-canary
    # pkgs.setapp

    # inputs.claude-lite.packages.${pkgs.stdenv.hostPlatform.system}.claude-lite
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
