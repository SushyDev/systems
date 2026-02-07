{ ... }:
{
	# --- SSH
	services.openssh.enable = true;
	services.openssh.ports = [ 22 ];
	services.openssh.settings.PasswordAuthentication = false;

	# --- Virtualisation
	virtualisation.docker.enable = true;

	# Rootless unfortunately hasn't worked for me yet.
	# Many issues with volume mounts / binds permissions.
	#virtualisation.docker.rootless = {
	#  enable = true;
	#  setSocketVariable = true;
	#};
}
