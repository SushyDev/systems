{
  inputs,
  lib,
  pkgs,
  ...
}:
{
  # claude-code tracks upstream through the claude-code input, the same overlay
  # quasar uses, rather than the system nixpkgs pin, which trails it by months.
  nixpkgs.overlays = [ inputs.claude-code.overlays.default ];

  home-manager.users.sushy = {
    home.stateVersion = "25.05";

    home.packages = [ pkgs.claude-code ];

    programs.bash.enable = true;

    programs.git.enable = true;

    # Same name and email as the other hosts. Not the signing key: its private
    # half lives in 1Password on quasar, so commits made here are not signed.
    imports = [ ../../modules/shared/user/git.nix ];
    programs.git.signing.key = lib.mkForce null;

    # Claude Code remote control, driving the flake checkout
    systemd.user.services.claude-remote = {
      Unit = {
        Description = "Claude Code Remote Control Service";
        Wants = [ "network-online.target" ];
        After = [ "network-online.target" ];
      };

      Install.WantedBy = [ "default.target" ];

      Service = {
        ExecStart = "${lib.getExe pkgs.claude-code} rc";
        WorkingDirectory = "/etc/nixos";
        Restart = "always";
        RestartSec = 10;

        # `claude rc` is a TUI that repaints every second; keep it out of the journal
        StandardOutput = "null";
        StandardError = "journal";

        # User units get a bare PATH; claude shells out to these. The system
        # profile is appended last so explicit pins above win, and so sed/awk/
        # curl/jq/systemctl resolve without listing every coreutils neighbour.
        Environment = [
          "PATH=${
            lib.makeBinPath [
              pkgs.coreutils
              pkgs.bash
              pkgs.git
              pkgs.openssh
              pkgs.kubectl
              pkgs.nix
            ]
          }:/run/current-system/sw/bin"
          "KUBECONFIG=/etc/rancher/k3s/k3s.yaml"
        ];
      };
    };

    # BuildX Patch until DDEV fixes their buildx plugin detection
    home.file.".docker/cli-plugins/docker-buildx".source =
      "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
  };
}
