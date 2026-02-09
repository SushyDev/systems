{ 
	config,
	inputs,
	lib,
	pkgs,
	setup,
	...
}:
{
	imports = [
		inputs.nix-plist-manager.homeManagerModules.default
		inputs.dotfiles.homeManagerModules.default
		../shared/nix-plist-manager.nix
		../shared/1password.nix
		../shared/ddev.nix
	];

	dotfiles = {
		enable = true;
		systemFlakePath = setup.systemFlakePath;
		git = {
			sshSignPackage = "${lib.getBin pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
		};
		ssh = {
			identityAgentPath = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
		};
	};

	programs.zsh.initContent = ''
EDITOR=nvim
PROJECTS=($HOME/Documents/projects)

PATH=$PATH:$HOME/Documents/nix/opdb/result/bin

eval "$(fnm env --use-on-cd)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 1Password plugin needs the completealiases to keep autocomplete working for the aliases it createas for each command
source $HOME/.config/op/plugins.sh
setopt completealiases

_glab_mr_title() {
	local -r branch_name=$(git symbolic-ref --short HEAD)
	local -r jira_ticket=$(echo $branch_name | grep -oE '[A-Z]+-[0-9]+')
	local -r feature_name=$(echo $branch_name | sed -E "s/(.*)$jira_ticket-//")

	if [ "$jira_ticket" ]; then
		echo "$jira_ticket :: $feature_name"
	else
		echo "$branch_name"
	fi
}

mkmr() {
	local -r branch_name="$1"

	if [ -z "$branch_name" ]; then
		echo "Usage: mkmr <base-branch>"
		return
	fi

	glab mr create \
		-y \
		--fill \
		-b "$branch_name" \
		-t "$(_glab_mr_title)" \
		-a "kjel"
}
	'';

	programs.ssh = {
		includes = [
			"${config.xdg.configHome}/ssh/1password_servers_config"
		];
	};

	home.packages = [ 
		pkgs.slack
		pkgs.phpstorm
		pkgs.glab

		# K8S
		pkgs.terraform
		pkgs.packer
		pkgs.hcloud
		pkgs.talosctl
	];

	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
	};

	# The state version is required and should stay at the version you
	# originally installed.
	home.stateVersion = "25.05";
}
