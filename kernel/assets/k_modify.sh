#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-m] args ...
#%
#% DESCRIPTION
#% This script is called by the [-m] flag. It requires root
#% privilege. It allows the modification to the config of an
#% already installed kernel. It will open the config menu,
#% then check if any edits were made and if so it will create
#% a .diff file in the config directory of changes that were
#% made. Then it will recompile the kernel and pass it to
#% k_install for reinstallation.
#%
#% OPTIONS
#% Receives kernel version-name as a parameter $1.
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

[[ "$1" =~ $(uname -r) ]] && exoe "${1} is the currently running kernel"
[[ ! -d $BUILD_DIR/linux-$1 ]] && cp -r "$SRC_DIR"/linux-"$1" "$BUILD_DIR"/
cd "$BUILD_DIR"/linux-"${1}" || exoe "${1} not found"
read -n 1 -p $'\033[1;37mCreate backup of kernel source? \033[0m[y/N]: ' REPLY
if [[ ${REPLY:-N} =~ ^[Yy]$ ]]; then
    sudo "$k_path"/assets/k_backup.sh "${1}"
fi
local oldSum=$(md5sum .config)
make "$KERNEL_MENU"
local newSum=$(md5sum .config)
if [[ $oldSum != "$newSum" ]]; then
    [[ ! -d "$HOME"/.config/kernel/configs/"$(date +"%Y-%m-%d")" ]] && mkdir -p "$HOME"/.config/kernel/configs/"$(date +"%Y-%m-%d")"
    diff .config.old .config > "$HOME"/.config/kernel/configs/"$(date +"%Y-%m-%d")"/"${1}-$(date | awk '{print $4}')".diff
else
    echo -e "\033[1;37mNo changes were made.\033[0m"
fi
read -n 1 -p $'\n\033[1;37mRecompile and install? \033[0m[y/N]: ' REPLY
if [[ $REPLY =~ ^[Yy]$ ]]; then
    make clean
    make -j$(($(nproc) - $(nproc) / 4)) || exoe "Compilation failed"
    sudo "$k_path"/assets/k_install.sh "${1}" "$BUILD_DIR"
else
    exit 0
fi
