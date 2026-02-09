{ lib, pkgs, systemConfig, ... }:
let
	hasDdev = lib.any (pkg: pkg.pname or "" == "ddev") systemConfig.environment.systemPackages;
in

# Provide DDEV command autocompletions for artisan and magento commands
# Only deploy if DDEV is in system packages
lib.mkIf hasDdev
{
	home.file.".ddev/commands/web/autocomplete/artisan" = {
		source = ./ddev/artisan.sh;
		executable = true;
	};
	home.file.".ddev/commands/web/autocomplete/magento" = {
		source = ./ddev/magento.sh;
		executable = true;
	};

	# Add activation script to rebuild ddev global commands after files are written
	home.activation.ddevFixCommands = lib.hm.dag.entryAfter ["writeBoundary"] ''
		if command -v ddev &> /dev/null; then
			$DRY_RUN_CMD ddev utility fix-commands || true
		fi
	'';
}
