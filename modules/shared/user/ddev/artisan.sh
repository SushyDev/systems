#!/usr/bin/env bash

# Requires: ddev config --webimage-extra-packages bash-completion
# Then put this script in ~/.ddev/commands/web/autocomplete/artisan
# chmod +x ~/.ddev/commands/web/autocomplete/artisan
# Then restart your ddev projects

# check if we are in a Laravel project.
[[ -f artisan ]] || exit 0
# define a unique cache file path based on the project directory.
# this ensures different projects have different completion caches.
readonly CACHE_FILE="/tmp/artisan_$(echo "$PWD" | sha256sum | cut -c1-10).sh"
# regenerate the cache file if it doesn't exist or if the artisan file has been updated.
# this is a good heuristic for detecting new commands.
[[ ! -f "$CACHE_FILE" || artisan -nt "$CACHE_FILE" ]] && php artisan completion bash > "$CACHE_FILE"
# source the cached script to make `_sf_artisan` available.
# this is fast because it's just reading a local file.
source /etc/bash_completion
source "$CACHE_FILE"
# set env variables required for artisan's bash completion script
readonly COMP_WORDS=("$@")
readonly COMP_CWORD=$(($# - 1))
# run the actual script
_sf_artisan
# output the result (which was stored in COMPREPLY) as a new-line delimited string
printf "%s\n" "${COMPREPLY[@]}"
