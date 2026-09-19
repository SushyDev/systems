{ config, pkgs, ... }:
let
  # The rules ConfigMap is built byte-for-byte here rather than passed through
  # the chart's `customRules` value.
  #
  # Why: services.k3s.autoDeployCharts serialises `values` into a HelmChart CR's
  # `valuesContent`, which is a double-quoted YAML scalar containing JSON. The
  # emitter line-wraps that scalar at ~80 columns, and when a "\n" escape
  # straddles the wrap the backslash and the n end up on different lines. YAML
  # line folding then collapses them into a literal " n", corrupting the rules
  # file. Any sufficiently long multi-line string in `values` hits this.
  #
  # Keeping the rules in their own YAML file also means they can be linted and
  # edited normally, and they stay portable if falco is ever packaged properly.
  rulesConfigMap = pkgs.runCommand "pulsar-falco-rules.yaml" { } ''
    {
      echo 'apiVersion: v1'
      echo 'kind: ConfigMap'
      echo 'metadata:'
      echo '  name: pulsar-falco-rules'
      echo '  namespace: falco'
      echo 'data:'
      echo '  pulsar-stylesmuggler.yaml: |'
      ${pkgs.gnused}/bin/sed 's/^/    /' ${./falco/stylesmuggler.yaml}
      echo '  pulsar-magento-webshell.yaml: |'
      ${pkgs.gnused}/bin/sed 's/^/    /' ${./falco/magento-webshell.yaml}
    } > $out
  '';
in
{
  # --- Falco (runtime security monitoring)
  #
  # Deployed as a k3s-managed Helm chart rather than a NixOS package: falco is
  # not in nixpkgs (only falcoctl is), and packaging it means owning a large
  # C++/CMake build whose bundled-dependency path is documented as failing even
  # on a clean Ubuntu. For a security tool a stale local package is worse than
  # none -- upstream ships rule and CVE updates continuously.
  #
  # driver.kind = modern_ebpf: a CO-RE eBPF program, so nothing compiles against
  # kernel headers and a kernel bump cannot break it. Needs >= 5.8; host is 6.18.
  #
  # Falco instruments the kernel, so it sees every container on the box -- the
  # Docker workloads as well as anything in k3s. That matters here because
  # Magento is still on compose.

  # The Discord webhook is rendered from sops straight into a Kubernetes Secret
  # manifest. falcosidekick consumes it with `envFrom: secretRef`, so the URL
  # never appears in Helm values, in the Nix store, or in `helm get values`.
  sops.templates."falcosidekick-discord.yaml" = {
    content = ''
      apiVersion: v1
      kind: Secret
      metadata:
        name: falcosidekick-discord
        namespace: falco
      type: Opaque
      stringData:
        DISCORD_WEBHOOKURL: "${config.sops.placeholder."alerting/discord_webhook"}"
    '';
  };

  services.k3s.manifests = {
    falcosidekick-discord.source = config.sops.templates."falcosidekick-discord.yaml".path;
    pulsar-falco-rules.source = rulesConfigMap;
  };

  services.k3s.autoDeployCharts.falco = {
    repo = "https://falcosecurity.github.io/charts";
    name = "falco";
    version = "9.1.0";
    hash = "sha256-KnZ9auzPI5LF4mOuH14JUFIK/+OpkI/3mGrCE2ScRbQ=";
    targetNamespace = "falco";
    createNamespace = true;

    values = {
      driver = {
        enabled = true;
        kind = "modern_ebpf";
      };

      # No Kubernetes metadata collector: it deploys a second component to
      # enrich events with pod labels, and the workloads worth watching are
      # currently Docker containers it would know nothing about.
      collectors.kubernetes.enabled = false;

      falco = {
        json_output = true;
        json_include_output_property = true;
        # The custom rules live in their own mount, added to the default list.
        rules_files = [
          "/etc/falco/falco_rules.yaml"
          "/etc/falco/falco_rules.local.yaml"
          "/etc/falco/rules.d"
          "/etc/falco/pulsar-rules.d"
        ];
      };

      mounts = {
        volumes = [
          {
            name = "pulsar-rules";
            configMap.name = "pulsar-falco-rules";
          }
        ];
        volumeMounts = [
          {
            name = "pulsar-rules";
            mountPath = "/etc/falco/pulsar-rules.d";
            readOnly = true;
          }
        ];
      };

      falcosidekick = {
        enabled = true;
        replicaCount = 1;
        config = {
          existingSecret = "falcosidekick-discord";
          # Everything NOTICE and above reaches Discord. The custom rules are
          # all CRITICAL; this leaves headroom for upstream rules without
          # drowning the channel.
          discord.minimumpriority = "notice";
        };
      };
    };
  };
}
