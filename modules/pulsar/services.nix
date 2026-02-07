{ ... }:
{
	# --- SSH
	services.openssh.enable = true;
	services.openssh.ports = [ 22 ];
	
	# Security settings
	services.openssh.settings = {
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
	};

	# --- Virtualisation
	virtualisation.docker.enable = true;

	# Rootless unfortunately hasn't worked for me yet.
	# Many issues with volume mounts / binds permissions.
	#virtualisation.docker.rootless = {
	#  enable = true;
	#  setSocketVariable = true;
	#};
}
