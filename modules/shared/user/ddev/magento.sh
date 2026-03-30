#!/usr/bin/env bash

# Requires: ddev config --webimage-extra-packages bash-completion
# Then put this script in ~/.ddev/commands/web/autocomplete/magento
# chmod +x ~/.ddev/commands/web/autocomplete/magento
# Then restart your ddev projects

# check if we are in a magento project by looking for bin/magento
if [ ! -f bin/magento ]; then
	exit 0
fi
# load bash completion for magento if it is not declared
if ! declare -F _sf_magento >/dev/null; then
	source /etc/bash_completion
	eval $(php bin/magento completion bash)
fi
# set env variables required for magento's bash completion script
COMP_WORDS=("$@")
COMP_CWORD=$(($# - 1))
# run the actual script
_sf_magento
# output the result (which was stored in COMPREPLY) as a new-line delimited string
printf "%s\n" "${COMPREPLY[@]}"
