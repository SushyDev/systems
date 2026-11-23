{ pkgs, ... }:
{
  # --- Programs
  environment.systemPackages = [
    pkgs.vim
    pkgs.jq
    pkgs.gitMinimal
    # For creating repos and deploy keys from the box; the GitOps workflow
    # otherwise needs a laptop round-trip for every repo operation.
    pkgs.gh
    pkgs.opencode

    # I can just nix-shell -p these
    #pkgs.dnsutils
    #pkgs.btop
  ];
}
