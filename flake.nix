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
			# url = "path:/Users/sushy/Documents/Projects/nix-darwin-apps";
			url = "github:sushydev/nix-darwin-apps?ref=main";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		nix-plist-manager = {
			# url = "path:/Users/sushy/Documents/Projects/nix-plist-manager-v2";
			url = "github:sushydev/nix-plist-manager?ref=main";
			inputs.nixpkgs.follows = "nixpkgs";
		};

		dotfiles = {
			# url = "path:/Users/sushy/Documents/Projects/dotfiles";
			type = "git";
			url = "https://github.com/sushydev/dotfiles";
			submodules = true;
		};

		sushy-lib = {
			url = "github:sushydev/nix-lib";
			inputs.nixpkgs.follows = "nixpkgs";
		};
	};

	outputs = { self, nixpkgs, disko, determinate, home-manager, plasma-manager, nix-darwin, nix-plist-manager, ... }@inputs:
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
					managedUsers = [ "sushy" "work" ];
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
					nixGroupId = 101;
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
	in
	{
		nixosConfigurations.pc = nixpkgs.lib.nixosSystem systemPc;
		darwinConfigurations.quasar = nix-darwin.lib.darwinSystem systemQuasar;
		nixosConfigurations.pulsar = nixpkgs.lib.nixosSystem systemPulsar;
	};
}
