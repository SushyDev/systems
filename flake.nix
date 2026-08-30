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

    sushy-lib = {
      url = "github:sushydev/nix-lib";
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
      url = "github:sushydev/nixos-sheng?ref=feature/update-kernel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      #url = "path:/Users/work/Documents/Projects/dotfiles";
      url = "https://github.com/sushydev/dotfiles";
      type = "git";
      ref = "main";
      submodules = true;
    };

    claude-lite = {
      url = "path:/Users/work/Documents/Projects/claude-lite";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      determinate,
      home-manager,
      plasma-manager,
      nix-darwin,
      nix-plist-manager,
      nixos-sheng,
      ...
    }@inputs:
    let
      systemPc = {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          setup = {
            primaryUser = "sushy";
            managedUsers = [ systemPc.specialArgs.setup.primaryUser ];
            managedUsersAndRoot = [ "root" ] ++ systemPc.specialArgs.setup.managedUsers;
            nixGroupMembers = [ systemPc.specialArgs.setup.primaryUser ];
            nixGroupName = "nix";
            nixGroupId = 101;
            systemFlakePath = "/etc/nixos";
          };
        };
        modules = [
          determinate.nixosModules.default
          ./modules/pc/configuration.nix

          home-manager.nixosModules.home-manager
          ./modules/pc/home-manager.nix
        ];
      };

      systemQuasar = {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
          setup = {
            managedUsers = [
              "sushy"
              "work"
            ];
            managedUsersAndRoot = systemQuasar.specialArgs.setup.managedUsers ++ [ "root" ];
            nixGroupName = "nix";
            nixGroupId = 503;
            systemFlakePath = "/private/etc/nixdarwin";
          };
        };
        modules = [
          ./modules/quasar/configuration.nix

          determinate.darwinModules.default
          ./modules/quasar/determinate.nix

          nix-plist-manager.darwinModules.default
          ./modules/quasar/plist-manager.nix

          home-manager.darwinModules.home-manager
          ./modules/quasar/home-manager.nix
        ];
      };

      systemPulsar = {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          disko = disko;
          setup = {
            primaryUser = "sushy";
            managedUsers = [ systemPulsar.specialArgs.setup.primaryUser ];
            managedUsersAndRoot = [ "root" ] ++ systemPulsar.specialArgs.setup.managedUsers;
            nixGroupMembers = [ systemPulsar.specialArgs.setup.primaryUser ];
            nixGroupName = "nix";
            nixGroupId = 502;
            systemFlakePath = "/etc/nixos";
          };
        };
        modules = [
          determinate.nixosModules.default
          disko.nixosModules.disko
          ./modules/pulsar/disko/btrfs-raid1.nix

          ./modules/pulsar/configuration.nix

          home-manager.nixosModules.home-manager
          ./modules/pulsar/home-manager.nix
        ];
      };

      # Xiaomi Pad 6S Pro. Built through nixos-sheng.lib.shengSystem rather
      # than nixpkgs.lib.nixosSystem: that wrapper pins aarch64-linux, adds
      # the sheng overlay (shengKernel, shengPackages), sets allowUnfree for
      # the QTEE and firmware blobs, and imports nixos-sheng's own modules.
      # It takes modules/specialArgs but not a whole nixosSystem attrset,
      # which is why this one is not shaped like the three above.
      systemSheng = {
        modules = [
          ./modules/sheng/configuration.nix

          home-manager.nixosModules.home-manager
          ./modules/sheng/home-manager.nix
        ];
        specialArgs = {
          inherit inputs;
          setup = {
            primaryUser = "sushy";
            managedUsers = [ systemSheng.specialArgs.setup.primaryUser ];
            managedUsersAndRoot = [ "root" ] ++ systemSheng.specialArgs.setup.managedUsers;
            nixGroupMembers = [ systemSheng.specialArgs.setup.primaryUser ];
            nixGroupName = "nix";
            nixGroupId = 101;
            systemFlakePath = "/etc/nixos";
          };
        };
      };

      shengImageScript = nixpkgs.legacyPackages.${systemQuasar.system}.writeShellApplication {
        name = "sheng-image";
        runtimeInputs = with nixpkgs.legacyPackages.${systemQuasar.system}; [
          coreutils
          gnutar
        ];
        text = builtins.readFile ./scripts/sheng-image;
      };
    in
    {
      nixosConfigurations.pc = nixpkgs.lib.nixosSystem systemPc;
      darwinConfigurations.quasar = nix-darwin.lib.darwinSystem systemQuasar;
      nixosConfigurations.pulsar = nixpkgs.lib.nixosSystem systemPulsar;
      nixosConfigurations.sheng = nixos-sheng.lib.shengSystem systemSheng;

      # The rootfs image itself. Only buildable on an aarch64-linux builder;
      # from this Mac use `nix run .#sheng`, which drives the container.
      packages.aarch64-linux.sheng = self.nixosConfigurations.sheng.config.system.build.shengImage;

      # U-Boot, straight from nixos-sheng -- it takes nothing from any host
      # config, so it is re-exported rather than rebuilt here.
      packages.aarch64-linux.sheng-u-boot = nixos-sheng.packages.aarch64-linux.u-boot;

      apps.${systemQuasar.system} = {
        sheng = {
          type = "app";
          program = nixpkgs.lib.getExe shengImageScript;
        };
      }
      // nixos-sheng.apps.${systemQuasar.system};
    };
}
