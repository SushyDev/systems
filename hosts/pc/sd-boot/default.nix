# systemd-boot patched to mirror its menu across every display and read XInput gamepads.
# Stock sd-boot stays the UEFI default; this one gets its own entry, reachable via
# `sdboot-mg-next-boot`. Press `p` in the menu to see which displays and pads it found.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.boot.loader.systemd-boot.multigop;

  package = pkgs.callPackage ./package.nix { };

  efiArch = pkgs.stdenv.hostPlatform.efiArch;
  espPath = "EFI/sdbootmg/sdbootmg${efiArch}.efi";
  efiPath = "\\EFI\\sdbootmg\\sdbootmg${efiArch}.efi";
  label = "systemd-boot (multi-display)";

  esp = config.boot.loader.efi.efiSysMountPoint;

  # Matches both "Boot0003* label" and "Boot0003 label".
  findEntry = ''sed -n 's/^Boot\([0-9A-Fa-f]\{4\}\)\*\? ${label}$/\1/p' '';

  # Picking it deliberately is the whole point while it is unproven.
  select = pkgs.writeShellApplication {
    name = "sdboot-mg-next-boot";
    runtimeInputs = [
      pkgs.efibootmgr
      pkgs.gnused
      pkgs.coreutils
    ];
    text = ''
      num=$(efibootmgr | ${findEntry} | head -n1)
      if [ -z "$num" ]; then
        echo "No '${label}' boot entry found. Has this generation been activated?" >&2
        exit 1
      fi
      efibootmgr --bootnext "$num" --quiet
      echo "The next boot only will use '${label}' (Boot$num). Reboot to try it."
      echo "Nothing is persisted: any boot after that goes back to stock systemd-boot."
    '';
  };
in
{
  options.boot.loader.systemd-boot.multigop = {
    enable = lib.mkEnableOption "the patched systemd-boot that mirrors its menu across all displays";

    reconnect = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Force a display-controller re-probe while the menu waits for input, to try to pick up a
        monitor that was powered off when the firmware ran. This tears down and rebinds the GPU's
        UEFI driver, which on some firmware leaves the console dead until the next reboot, so it is
        off by default.
      '';
    };

    makeDefault = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Put the patched loader first in the UEFI boot order. Leave this off until it has been proven
        on this hardware: with it off, stock systemd-boot stays the default and the patched build is
        reachable only via `sdboot-mg-next-boot` or the firmware's own boot menu, so a bad build
        costs one reboot instead of a recovery session.

        Only applies when the NVRAM entry is first created. Reorder with `efibootmgr` afterwards.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.boot.loader.systemd-boot.enable;
        message = "boot.loader.systemd-boot.multigop requires boot.loader.systemd-boot.enable.";
      }
      {
        assertion = config.boot.loader.efi.canTouchEfiVariables;
        message = "boot.loader.systemd-boot.multigop needs boot.loader.efi.canTouchEfiVariables to register its own NVRAM entry.";
      }
    ];

    boot.loader.systemd-boot.extraFiles.${espPath} = "${package}/systemd-boot${efiArch}.efi";

    # Runs after the builder has written loader.conf and run bootctl, so appending is safe; the
    # builder rewrites the file from scratch on every activation. Stock sd-boot silently ignores
    # keys it does not know, so one shared loader.conf serves both binaries.
    boot.loader.systemd-boot.extraInstallCommands = ''
      {
        echo "multigop yes"
        echo "gamepad yes"
        ${lib.optionalString cfg.reconnect ''echo "multigop-reconnect yes"''}
      } >> ${esp}/loader/loader.conf

      # Registering a convenience boot entry must never be able to fail an activation, so this runs
      # in a subshell that only warns. The loader is already on the ESP either way, and the firmware
      # boot menu can reach it even with no NVRAM entry.
      register_multigop_entry() {
          local espDev espName espPart espDisk prevOrder newNum

          # The ESP is not in fileSystems on this host -- systemd-gpt-auto-generator mounts it -- so
          # ask the kernel where it is rather than hardcoding a device.
          espDev=$(${pkgs.util-linux}/bin/findmnt -no SOURCE ${esp}) || return 1
          espName=$(${pkgs.coreutils}/bin/basename "$espDev")
          [ -r "/sys/class/block/$espName/partition" ] || return 1
          espPart=$(${pkgs.coreutils}/bin/cat "/sys/class/block/$espName/partition")
          espDisk="/dev/$(${pkgs.coreutils}/bin/basename \
              "$(${pkgs.coreutils}/bin/readlink -f "/sys/class/block/$espName/..")")"

          if ${pkgs.efibootmgr}/bin/efibootmgr | ${pkgs.gnugrep}/bin/grep -q -- '${label}$'; then
              return 0
          fi

          # --create prepends to BootOrder, which would silently make this the default, so capture
          # the order first and put it back with us in the requested position.
          prevOrder=$(${pkgs.efibootmgr}/bin/efibootmgr \
              | ${pkgs.gnused}/bin/sed -n 's/^BootOrder: //p')

          ${pkgs.efibootmgr}/bin/efibootmgr --quiet --create \
              --disk "$espDisk" --part "$espPart" \
              --loader '${efiPath}' --label '${label}' || return 1

          newNum=$(${pkgs.efibootmgr}/bin/efibootmgr \
              | ${pkgs.gnused}/bin/${findEntry} | ${pkgs.coreutils}/bin/head -n1)
          [ -n "$newNum" ] && [ -n "$prevOrder" ] || return 0

          ${pkgs.efibootmgr}/bin/efibootmgr --quiet --bootorder \
              ${if cfg.makeDefault then ''"$newNum,$prevOrder"'' else ''"$prevOrder,$newNum"''}
      }

      if ! (register_multigop_entry); then
          echo "warning: could not register the '${label}' NVRAM entry." >&2
          echo "warning: the loader is still at ${espPath} on the ESP; pick it from the firmware boot menu." >&2
      fi
    '';

    environment.systemPackages = [
      select
      pkgs.efibootmgr
    ];
  };
}
