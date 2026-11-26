{ config, inputs, ... }:
{
  imports = [ inputs.devos.nixosModules.devos ];

  # --- Bentix development OS
  #
  # The panel and the agents it runs, as the user services devos.service and
  # devos-tunnel.service, from the module in the devos checkout (input `devos`).
  # Port 4020 has no login: it stays closed in the firewall, and the panel is
  # reached only through the Cloudflare tunnel.

  # The tunnel token lives in its own sops file, so adding it needs only the
  # public recipients of ../../.sops.yaml: ~/quasar-claude/devos-token.sh.
  sops.secrets."devos/cloudflared_token" = {
    sopsFile = ./secrets/devos.yaml;
    owner = "sushy";
  };

  services.devos = {
    enable = true;
    user = "sushy";
    checkout = "/home/sushy/.local/share/bentix_devos/agents/checkouts/bentix_devos";
    workstation = "pulsar";
    tunnel = {
      enable = true;
      tokenFile = config.sops.secrets."devos/cloudflared_token".path;
    };
  };
}
