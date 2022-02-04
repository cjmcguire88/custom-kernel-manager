#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel (main)
#%
#% DESCRIPTION
#% This script can be considered the main "portal" to the
#% program. It first ensures it wasn't called as root then
#% ensures that the config file is present before proceeding
#% to main. Then it will parse any flags and call the
#% appropriate scripts or call k_info.sh if no flags are 
#% present.
#%
#% OPTIONS
#% -[d] [i] [b] [m] [r] [a] [c] [p] [u] [n] [h] OPTARGS ...
#% Receives flags and optional arguments depending on flag.
#%
#================================================================
#- IMPLEMENTATION
#-    version         custom-kernel-manager 1.0
#-    author          Jason McGuire
#-    copyright       None
#-    license         MIT
#-
#================================================================
# END_OF_HEADER
#================================================================

exoe() {
    echo -e "\033[1;31m${1}\033[0m" >&2
    exit 1
}
export k_path="$(dirname $(realpath $0 ))"
# This is the "main portal" to the above functions.
main() {
    source $HOME/.config/kernel/kernel.conf
    while getopts ':d:i:b:m:r:a:c:punh' flag; do
        case "${flag}" in
            d)
                source $k_path/assets/k_download.sh "${OPTARG}"; exit
                ;;
            i)
                source $k_path/assets/k_prepare.sh "${OPTARG}"; exit
                ;;
            b)
                sudo $k_path/assets/k_backup.sh "${OPTARG}"; exit
                ;;
            m)
                source $k_path/assets/k_modify.sh "${OPTARG}"; exit
                ;;
            r)
                sudo $k_path/assets/k_remove.sh "${OPTARG}"; exit
                ;;
            a)
                sudo $k_path/assets/k_restore.sh "${OPTARG}"; exit
                ;;
            c)
                source $k_path/assets/k_cl.sh "${OPTARG}"; exit
                ;;
            p)
                source $k_path/assets/k_patch.sh; exit
                ;;
            u)
                source $k_path/assets/k_update.sh; exit
                ;;
            n)
                source $k_path/assets/k_new.sh; exit
                ;;
            h)
                source $k_path/assets/k_help.sh; exit
                ;;
            :)
                exoe "Requires argument:\033[0m see -h"
                ;;
            *)
                exoe "Invalid Usage:\033[0m see -h"
                ;;
        esac
    done
    source $k_path/assets/k_info.sh
}
if [ "$EUID" -eq 0 ]; then
    exoe "Do not run as root"
elif [[ ! -f $HOME/.config/kernel/kernel.conf ]]; then
    exoe "Can't find configuration file."
else
    main "$@"
fi
