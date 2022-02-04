#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-c] args ...
#%
#% DESCRIPTION
#% This script is called by the [-c] flag and other scripts when
#% installing a new kernel. It downloads the changelog for the
#% version passed to it using the $DOWNLOADER specified in
#% kernel.conf. It then displays the changelog using the
#% $CL_VIEWER program specified in kernel.conf.
#%
#% OPTIONS
#% Recieves kernel version as a parameter $1.
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

MAJ_VER="${1:0:1}"
[[ "$1" =~ ^[0-9]+\.[0-9]+\.?[0-9]*$ ]] || exoe "Not a valid kernel version"
echo -e "\n\033[1;37mRetrieving linux-${1} Changelog\033[0m"
case $DOWNLOADER in
    1)
        wget "$PROTO"://cdn.kernel.org/pub/linux/kernel/v"${MAJ_VER}".x/ChangeLog-"${1}" -P "$RUN_DIR" > /dev/null 2>&1 || exoe "$1 not found"
        ;;
    2)
        aria2c -x 3 -m 3 -d "$RUN_DIR" "$PROTO"://cdn.kernel.org/pub/linux/kernel/v"${MAJ_VER}".x/ChangeLog-"${1}" > /dev/null 2>&1 || exoe "$1 not found"
        ;;
    3)
        curl -sL -o "$RUN_DIR"/ChangeLog-"${1}" "$PROTO"://cdn.kernel.org/pub/linux/kernel/v"${MAJ_VER}".x/ChangeLog-"${1}"
esac
"$CL_VIEWER" "$RUN_DIR"/ChangeLog-"${1}"
rm -rf "$RUN_DIR"/ChangeLog-"${1}"
