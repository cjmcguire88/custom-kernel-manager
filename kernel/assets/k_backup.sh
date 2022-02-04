#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-b] args ...
#%
#% DESCRIPTION
#% This script is called by either the [-b] flag or by another
#% script that modifies the kernel. It is always called as root
#% as it operates in a directory that requires root privilege.
#% It creates a .tar.gz archive of the source directory for the
#% version passed to it in the $SRC_DIR/backups folder.
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

exoe() {
    echo -e "\033[1;31m${1}\033[0m" >&2
    exit 1
}

source /home/"$SUDO_USER"/.config/kernel/kernel.conf

[[ ! -d $SRC_DIR/backups ]] && mkdir "$SRC_DIR"/backups
[[ -f $SRC_DIR/backups/${1}.tar.gz ]] && exoe "Archive already exists"
[[ ! -d $SRC_DIR/linux-${1} ]] && exoe "\033[0mlinux-${1}\033[1;31m not installed"
echo -e "\n\033[1;37m$SRC_DIR/\033[1;32mlinux-${1}\033[1;37m > $SRC_DIR/backups/\033[1;34m${1}.tar.gz\033[0m"
tar -czvf "$SRC_DIR"/backups/"${1}".tar.gz -C "$SRC_DIR"/ linux-"${1}"
echo -e "\nArchive \033[0;32m${1}.tar.gz\033[0m created in $SRC_DIR/backups"
