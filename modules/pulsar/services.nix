{ ... }:
{
	# SSH Configuration
	services.openssh.enable = true;
	services.openssh.ports = [ 22 ];
	services.openssh.settings.PasswordAuthentication = false;

	# Virtualisation - Docker
	virtualisation.docker.enable = true;

	# Uncomment for rootless docker (note: may have volume mount issues)
	# virtualisation.docker.rootless = {
	#   enable = true;
	#   setSocketVariable = true;
	# };
}
