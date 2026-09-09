{ config, pkgs, ... }:
let
  # Local repository, on the same btrfs RAID1 array as the data it protects.
  # That covers what actually goes wrong -- `DROP TABLE`, a bad setup:upgrade,
  # a compromised container, "I deleted the wrong volume" -- but NOT loss of the
  # machine. Off-site is a one-line change: point `repository` at
  # "sftp:uXXXXXX@uXXXXXX.your-storagebox.de:/backups/pulsar".
  repo = "/var/backup/restic";

  dumpDir = "/var/backup/staging";

  vol = name: "/var/lib/docker/volumes/${name}/_data";

  notifyUnit = "notify-discord@";

  common = {
    repository = repo;
    passwordFile = config.sops.secrets."restic/password".path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 7"
      "--keep-weekly 4"
      "--keep-monthly 6"
    ];
  };
in
{
  # --- Backups (restic)
  #
  # SCOPE, deliberately narrow: the hosted services only -- Magento today,
  # WordPress when it lands. The media stack, game servers, ollama models and
  # the rest of the homelab are NOT backed up. They are large (the Minecraft
  # world alone is 99 GB), re-downloadable or re-generatable, and including them
  # buries the data that actually matters in noise.
  #
  # What is genuinely irreplaceable here is small:
  #   magento_pub   13 GB  -- product media, cannot be regenerated
  #   the database  ~1 GB  -- as a logical dump, not a datadir copy
  #   config        <1 MB  -- compose files, .env, env.php, /etc/nixos
  #
  # Deliberately NOT backed up, because all of it is derived state that Magento
  # rebuilds: magento_generated (81M, `setup:di:compile`), opensearch_data
  # (`indexer:reindex`), valkey_* (cache/session), rabbitmq_data (queue
  # topology, re-declared on boot), and mariadb_data as raw files (superseded by
  # the logical dump below).

  systemd.tmpfiles.rules = [
    "d /var/backup 0700 root root -"
    "d ${repo} 0700 root root -"
    "d ${dumpDir} 0700 root root -"
  ];

  # --- Alerting: one generic failure notifier
  #
  # systemd passes the failed unit in %i, so any unit opts in with one line:
  #     unitConfig.OnFailure = "notify-discord@%n.service";
  # This is the only hand-written glue in the alerting path.
  systemd.services.${notifyUnit} = {
    description = "Report failure of %i to Discord";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    path = [
      pkgs.curl
      pkgs.systemd
      pkgs.jq
      pkgs.coreutils
      pkgs.inetutils
    ];
    script = ''
      unit="$1"
      webhook="$(cat ${config.sops.secrets."alerting/discord_webhook".path})"
      detail="$(journalctl -u "$unit" -n 15 --no-pager -o cat 2>/dev/null | tail -c 1500)"

      payload="$(jq -nc \
        --arg u "$unit" \
        --arg h "$(hostname)" \
        --arg d "$detail" \
        '{username:"pulsar",
          embeds:[{title:("❌ " + $u + " failed"),
                   description:("```\n" + $d + "\n```"),
                   color:15158332,
                   footer:{text:$h}}]}')"

      curl -sS -m 20 -H 'Content-Type: application/json' -d "$payload" "$webhook" >/dev/null
    '';
    scriptArgs = "%i";
  };

  # --- Magento: database (mydumper)
  #
  # A logical dump, not a copy of mariadb_data: an InnoDB datadir captured while
  # the server is running is not reliably restorable.
  #
  # mydumper rather than mariadb-dump: it dumps and restores in parallel
  # (-t 4), writes one file per table so a single table can be restored without
  # replaying the whole schema, and `myloader` reloads with the same
  # parallelism. --trx-tables tells it every table is transactional, which is
  # true for Magento (all InnoDB) and lets it take a consistent snapshot
  # without holding a global read lock across the dump.
  #
  # It connects over the Docker bridge to the container's own IP: the mariadb
  # service publishes no host port, and the image has no mydumper in it.
  # The password goes in a 0600 defaults-file, never in argv, because the
  # process list is world-readable.
  services.restic.backups.magento-db = common // {
    paths = [ "${dumpDir}/magento-db" ];

    backupPrepareCommand = ''
      set -euo pipefail
      C=appie-goossens-m2-mariadb-1

      if ! ${pkgs.docker}/bin/docker ps --format '{{.Names}}' | ${pkgs.gnugrep}/bin/grep -qx "$C"; then
        echo "WARNING: mariadb container not running -- no dump taken this run."
        exit 0
      fi

      IP=$(${pkgs.docker}/bin/docker inspect -f \
        '{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$C" | ${pkgs.gawk}/bin/awk '{print $1}')
      PW=$(${pkgs.docker}/bin/docker exec "$C" printenv MYSQL_ROOT_PASSWORD)

      CNF=${dumpDir}/.my.cnf
      ${pkgs.coreutils}/bin/install -m 0600 /dev/null "$CNF"
      printf '[client]\nuser=root\npassword=%s\n' "$PW" > "$CNF"

      ${pkgs.coreutils}/bin/rm -rf ${dumpDir}/magento-db
      ${pkgs.coreutils}/bin/mkdir -p ${dumpDir}/magento-db

      ${pkgs.mydumper}/bin/mydumper \
        --defaults-file="$CNF" \
        --host="$IP" --port=3306 \
        --database=magento \
        --outputdir=${dumpDir}/magento-db \
        --threads=4 \
        --compress=zstd \
        --trx-tables \
        --build-empty-files \
        --verbose=2

      ${pkgs.coreutils}/bin/rm -f "$CNF"
    '';

    backupCleanupCommand = ''
      ${pkgs.coreutils}/bin/rm -rf ${dumpDir}/magento-db ${dumpDir}/.my.cnf
    '';

    timerConfig = {
      OnCalendar = "03:00";
      RandomizedDelaySec = "15m";
      Persistent = true;
    };
  };

  # --- Magento: product media
  #
  # 13 GB / ~220k files. The one thing no dump and no rebuild can recreate.
  # pub/static and pub/media/catalog/product/cache are excluded: both are
  # regenerated from source images and static content deployment.
  services.restic.backups.magento-media = common // {
    paths = [ (vol "appie-goossens-m2_magento_pub") ];

    exclude = [
      "**/pub/static/**"
      "**/media/catalog/product/cache/**"
      "**/media/tmp/**"
    ];

    timerConfig = {
      OnCalendar = "03:30";
      RandomizedDelaySec = "15m";
      Persistent = true;
    };
  };

  # --- Configuration
  #
  # Tiny (<1 MB) and the highest-value-per-byte thing here. The .env and env.php
  # files still hold live credentials; the restic repository is encrypted, so
  # this is currently the only safe place they are stored.
  services.restic.backups.configs = common // {
    paths = [
      "/etc/nixos"
      "/home/sushy/docker/appie-goossens-m2"
    ];

    exclude = [
      "**/.direnv"
      "**/.git"
      "**/result"
      "/home/sushy/docker/appie-goossens-m2/dump"
    ];

    timerConfig = {
      OnCalendar = "04:00";
      RandomizedDelaySec = "15m";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-daily 14"
      "--keep-weekly 8"
      "--keep-monthly 12"
    ];
  };

  # Each job reports its own failure. Without this these are as silent as Flux
  # was for 150 days.
  systemd.services.restic-backups-magento-db.unitConfig.OnFailure = "${notifyUnit}%n.service";
  systemd.services.restic-backups-magento-media.unitConfig.OnFailure = "${notifyUnit}%n.service";
  systemd.services.restic-backups-configs.unitConfig.OnFailure = "${notifyUnit}%n.service";

  # restic for manual snapshot/restore work; mydumper ships myloader, which is
  # what a restore actually uses.
  environment.systemPackages = [
    pkgs.restic
    pkgs.mydumper
  ];
}
