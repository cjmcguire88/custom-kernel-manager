#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-p]
#%
#% DESCRIPTION
#% This script is called by the [-p] flag and other functions.
#% It creates a patches directory in the path it is called from
#% and then downloads any patches from links listed in $HOME/
#% .config/kernel/patchfile to the patches directory.
#%
#% OPTIONS
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

echo -e "\n\033[1;37mRetrieving patches\033[0m"
mkdir patches
cd patches || exoe "patches directory missing"
case $DOWNLOADER in
    1)
        wget -i "$PATCH_DIR"/patchfile || exoe "No patchfile or patches directory"
        ls
        ;;
    2)
        aria2c -i "$PATCH_DIR"/patchfile || exoe "No patchfile or patches directory"
        ;;
    3)
        xargs -n 1 curl -O < "$PATCH_DIR"/patchfile || exoe "No patchfile or patches directory"
        ls
        ;;
esac
read -n 1 -p $'\033[1;37mAre these the correct patches \033[0m[Y/n]: ' REPLY
echo
[[ $REPLY =~ ^[Nn]$ ]] && exit
echo -e "\n\033[1;37mpatches -> \033[0m$(pwd)"
cd ../
