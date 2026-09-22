#!/usr/bin/env bash

# Requires: ddev config --webimage-extra-packages bash-completion
# Then put this script in ~/.ddev/commands/web/autocomplete/magento
# chmod +x ~/.ddev/commands/web/autocomplete/magento
# Then restart your ddev projects

# check if we are in a magento project by looking for bin/magento
[[ -f bin/magento ]] || exit 0

# source bash_completion if not already loaded, then eval the magento completion script
if ! declare -F _sf_magento >/dev/null; then
  source /etc/bash_completion
  eval "$(php bin/magento completion bash)"
fi

# set env variables required for magento's bash completion script
readonly COMP_WORDS=("$@")
readonly COMP_CWORD=$(($# - 1))

# run the actual script
_sf_magento

# output the result (which was stored in COMPREPLY) as a new-line delimited string
printf "%s\n" "${COMPREPLY[@]}"
