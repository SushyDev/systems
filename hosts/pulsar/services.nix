{ pkgs, ... }:
{
  # --- SSH
  services.openssh.enable = true;
  services.openssh.ports = [ 22 ];

  # Security settings
  services.openssh.settings = {
    # Only the two named logins may start a session at all
    AllowUsers = [ "sushy" "kubeops" ];
    X11Forwarding = false;
    MaxAuthTries = 3;

    # Disable password authentication
    PasswordAuthentication = false;

    # Disable root login
    PermitRootLogin = "no";

    # Only allow key-based authentication
    PubkeyAuthentication = true;

    # Disable empty password login
    PermitEmptyPasswords = false;

    # Restrict authentication methods
    AuthenticationMethods = "publickey";

    # NOTE: UsePrivilegeSeparation was removed here on 2026-09-19. OpenSSH
    # dropped the option in 7.5 -- privilege separation has been mandatory and
    # non-configurable ever since -- and sshd logged
    # "Deprecated option UsePrivilegeSeparation" on every config parse. It read
    # like a hardening setting while doing nothing at all.

    # Close the keyboard-interactive path entirely. AuthenticationMethods above
    # already pins auth to publickey, so this changes nothing an attacker could
    # reach -- it just stops sshd offering a method that can never succeed.
    KbdInteractiveAuthentication = false;
  };

  # --- SSH brute-force protection
  #
  # Password auth is off, so none of the ~2700 failed attempts per day seen on
  # 2026-09-19 could ever have succeeded. This is about cost, not correctness:
  # it stops the box spending CPU and log volume on them, and keeps real signal
  # visible in `journalctl -u sshd`.
  #
  # ignoreIP carries the private ranges only. Self-lockout is a small risk
  # anyway: password auth is off, so reaching maxretry means five failed KEY
  # attempts, and a ban lasts an hour against a box with console access.
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    bantime = "1h";
    ignoreIP = [
      "127.0.0.0/8"
      "::1"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
      # No operator IP is listed here on purpose: this repository is PUBLIC, and
      # a residential address in it is a disclosure, not a convenience. If you
      # want one, add it on the host in a file outside git rather than here.
    ];
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "168h";
    };
  };

  # fail2ban's journal reader stopped consuming entries on 2026-11-17 and sat
  # there for six days. The process stayed alive and still answered
  # `fail2ban-client ping`, so Restart= never fired and nothing looked wrong --
  # 1110 matchable sshd failures in 24h produced 0 bans. This compares what
  # sshd reports against what fail2ban noticed, and bounces it on a mismatch.
  systemd.services.fail2ban-stall-check = {
    description = "Restart fail2ban if it has stopped reading the journal";
    serviceConfig.Type = "oneshot";
    path = [
      pkgs.systemd
      pkgs.gnugrep
      pkgs.coreutils
    ];
    script = ''
      sshd_fails=$(journalctl -u sshd --since '-60 min' -o cat 2>/dev/null \
        | grep -cE 'Invalid user|Failed password|Connection closed by (invalid|authenticating) user' || true)
      f2b_found=$(journalctl -u fail2ban --since '-60 min' -o cat 2>/dev/null \
        | grep -c 'Found' || true)

      # A quiet hour is not a stall, hence the floor: act only when sshd plainly
      # had something to report and fail2ban logged none of it.
      if [ "''${sshd_fails:-0}" -ge 10 ] && [ "''${f2b_found:-0}" -eq 0 ]; then
        echo "fail2ban logged 0 of $sshd_fails sshd failures in the last hour; restarting"
        systemctl restart fail2ban
      fi
    '';
  };

  systemd.timers.fail2ban-stall-check = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      RandomizedDelaySec = "5m";
      Persistent = true;
    };
  };

  # --- Virtualisation
  virtualisation.docker.enable = true;

  # Rootless unfortunately hasn't worked for me yet.
  # Many issues with volume mounts / binds permissions.
  #virtualisation.docker.rootless = {
  #  enable = true;
  #  setSocketVariable = true;
  #};

  # --- System optimizations

  # Enable zram for better memory management
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  # Enable earlyoom for better memory management under pressure
  services.earlyoom.enable = true;

  # Enable fstrim for SSD optimization
  services.fstrim.enable = true;

  # Disable unnecessary services
  services.printing.enable = false;
}
