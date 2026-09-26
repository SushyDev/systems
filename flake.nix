{
  description = "My systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    determinate = {
      url = "github:determinatesystems/determinate/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };


    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin-apps = {
      #url = "path:/Users/sushy/Documents/Projects/nix-darwin-apps";
      url = "github:sushydev/nix-darwin-apps?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-plist-manager = {
      #url = "path:/Users/sushy/Documents/Projects/nix-plist-manager";
      url = "github:sushydev/nix-plist-manager?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-sheng = {
      url = "github:sushydev/nixos-sheng?ref=feature/updates";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Tracks upstream Claude Code releases directly (nixpkgs lags behind) and
    # bundles its own node. nixpkgs is deliberately NOT followed here: the
    # upstream cachix cache only has hits for the flake's own pinned nixpkgs.
    claude-code = {
      url = "github:sadjow/claude-code-nix";
    };

    dotfiles = {
      #url = "path:/Users/work/Documents/Projects/dotfiles";
      url = "https://github.com/sushydev/dotfiles";
      type = "git";
      ref = "main";
      submodules = true;
    };

    # claude-lite = {
    #   url = "path:/Users/work/Documents/Projects/claude-lite";
    # };
  };

  outputs =
    {
      self,
      nixpkgs,
      nix-darwin,
      nixos-sheng,
      ...
    }@inputs:
    let
      specialArgs = { inherit inputs; };
      macPlatform = "aarch64-darwin";

      traitLib = import ./lib/traits { inherit (nixpkgs) lib; };
      traits = import ./modules/traits { inherit (nixpkgs) lib; };
      forEachSystem = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      shengImageScript = nixpkgs.legacyPackages.${macPlatform}.writeShellApplication {
        name = "sheng-image";
        runtimeInputs = with nixpkgs.legacyPackages.${macPlatform}; [
          coreutils
          gnutar
        ];
        text = builtins.readFile ./scripts/sheng-image;
      };
    in
    {
      nixosConfigurations = {
        pc = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/pc/configuration.nix ];
        };

        pulsar = nixpkgs.lib.nixosSystem {
          inherit specialArgs;
          modules = [ ./hosts/pulsar/configuration.nix ];
        };

        # Xiaomi Pad 6S Pro. shengSystem pins aarch64-linux, adds the sheng overlay,
        # allows the unfree firmware blobs and imports nixos-sheng's own modules.
        sheng = nixos-sheng.lib.shengSystem {
          inherit specialArgs;
          modules = [ ./hosts/sheng/configuration.nix ];
        };
      };

      darwinConfigurations.quasar = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        modules = [ ./hosts/quasar/configuration.nix ];
      };

      # The rootfs image itself. Only buildable on an aarch64-linux builder;
      # from this Mac use `nix run .#sheng`, which drives the container.
      packages.aarch64-linux.sheng = self.nixosConfigurations.sheng.config.system.build.shengImage;

      # U-Boot, straight from nixos-sheng -- it takes nothing from any host
      # config, so it is re-exported rather than rebuilt here.
      packages.aarch64-linux.sheng-u-boot = nixos-sheng.packages.aarch64-linux.u-boot;

      apps.${macPlatform} = {
        sheng = {
          type = "app";
          program = nixpkgs.lib.getExe shengImageScript;
        };
        traits = traitLib.mkTraitsApp {
          pkgs = nixpkgs.legacyPackages.${macPlatform};
          configurations = self.nixosConfigurations // self.darwinConfigurations;
        };
      }
      // nixos-sheng.apps.${macPlatform};

      checks = forEachSystem (
        system:
        traitLib.mkChecks {
          inherit traits specialArgs;
          pkgs = nixpkgs.legacyPackages.${system};
          nixos = {
            evaluate = nixpkgs.lib.nixosSystem;
            homeManager = traits.useHomeManager;
            hostPlatform = "x86_64-linux";
          };
          darwin = {
            evaluate = nix-darwin.lib.darwinSystem;
            homeManager = traits.useHomeManager;
            hostPlatform = macPlatform;
          };
        }
      );
    };
}
