{ ... }:
{
	systemd.services."*".serviceConfig = {
		ProtectSystem = "strict";
		ProtectHome = "read-only";
		ProtectKernelTunables = true;
		ProtectKernelModules = true;
		ProtectControlGroups = true;

		NoNewPrivileges = true;
		PrivateTmp = true;

		RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
	};

	systemd.services.sshd.serviceConfig = {
		ProtectHome = false;
		PrivateDevices = true;
		# SystemCallFilter = [ "@system-service" ];
		# SystemCallFilter = [ "@system-service" "~@resources" ];
		SystemCallFilter = [];
		SystemCallArchitectures = "native";
		MemoryDenyWriteExecute = true;
	};

	systemd.services.docker.serviceConfig = {
		ProtectSystem = "strict";
		PrivateDevices = true;
		ProtectHostname = true;
		NoNewPrivileges = true;
	};

	systemd.services.NetworkManager.serviceConfig = {
		PrivateDevices = true;
		ProtectHostname = true;
		MemoryDenyWriteExecute = true;
	};
}
