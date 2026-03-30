{ lib, pkgs, config, systemConfig ? null, ... }:
let
	hasDdev = lib.any (pkg: pkg.pname or "" == "ddev") (config.home.packages ++ systemConfig.environment.systemPackages);
in
lib.mkIf hasDdev {
	home.activation.ddevCreateDirs = lib.hm.dag.entryBefore ["linkGeneration"] ''
		mkdir -p ${config.home.homeDirectory}/.ddev/commands/web/autocomplete
	'';

	home.file.".ddev/commands/web/autocomplete/artisan" = {
		source = ./ddev/artisan.sh;
		executable = true;
		force = true;
	};
	home.file.".ddev/commands/web/autocomplete/magento" = {
		source = ./ddev/magento.sh;
		executable = true;
		force = true;
	};

	home.activation.ddevFixCommands = lib.hm.dag.entryAfter ["writeBoundary"] ''
		if command -v ddev &>/dev/null; then
			$DRY_RUN_CMD ddev utility fix-commands || true
		fi
	'';
}
