{ lib, pkgs, ... }:
{
  # The state version is required and should stay at the version you
  # originally installed.
  home.stateVersion = "25.05";

  # Disable Claude Code's co-author trailers on commits/PRs. Merged into the
  # existing settings.json instead of home.file so Claude can still write to it.
  home.activation.claudeCodeAttribution = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    settings="$HOME/.claude/settings.json"
    run mkdir -p "$HOME/.claude"
    [ -f "$settings" ] || run sh -c "echo '{}' > \"$settings\""
    tmp="$(mktemp)"
    ${pkgs.jq}/bin/jq '.attribution = { commit: "", pr: "" }' "$settings" > "$tmp" \
      && run sh -c "cat \"$tmp\" > \"$settings\""
    rm -f "$tmp"
  '';
}
