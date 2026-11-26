{ config, pkgs, ... }:
let
  # mdadm runs this for every event on the RAID 1 (md127), as root:
  #   $1 event (Fail, DegradedArray, RebuildFinished, TestMessage, ...)
  #   $2 array, $3 member device when the event has one
  # Same Discord channel and look as notify-discord@ in ./backups.nix.
  alert = pkgs.writeShellApplication {
    name = "mdadm-alert-discord";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
      pkgs.inetutils
    ];
    text = ''
      event="$1"
      array="''${2:-?}"
      member="''${3:-}"
      webhook="$(cat ${config.sops.secrets."alerting/discord_webhook".path})"

      case "$event" in
        Fail | FailSpare | DegradedArray | DeviceDisappeared | SparesMissing)
          icon="❌"; color=15158332 ;;
        TestMessage)
          icon="🧪"; color=3447003 ;;
        *)
          icon="ℹ️"; color=16776960 ;;
      esac

      detail="$(cat /proc/mdstat)"
      [ -n "$member" ] && detail="member: $member"$'\n\n'"$detail"

      payload="$(jq -nc \
        --arg t "$icon RAID $event on $array" \
        --arg d "$detail" \
        --arg h "$(hostname)" \
        --argjson c "$color" \
        '{username:"pulsar",
          embeds:[{title:$t, description:("```\n" + $d + "\n```"), color:$c, footer:{text:$h}}]}')"

      curl -sS -m 20 -H 'Content-Type: application/json' -d "$payload" "$webhook" >/dev/null
    '';
  };
in
{
  # --- RAID alerts
  #
  # Without MAILADDR or PROGRAM, mdmonitor exits at boot ("not monitoring"),
  # so a failing disk in the RAID 1 would have gone unnoticed.
  boot.swraid.mdadmConf = ''
    PROGRAM ${alert}/bin/mdadm-alert-discord
  '';
}
