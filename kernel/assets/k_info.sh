#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel
#%
#% DESCRIPTION
#% This script is called when no flags are passed to the program
#% and it will print out various info about installed kernels and
#% backups.
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

local M_TIME=$(stat "$SRC_DIR"/linux-"$(uname -r)"/arch/x86_64/boot/bzImage| awk -F " " '/Modify:/ {print $2}')
local KERNELS=$(ls "$KERNEL_DIR"/vmlinuz-linux*)
local BACKUPS=$(ls "$SRC_DIR"/backups/*.tar.gz)
local UKI=$(ls "$KERNEL_DIR"/*.efi)

echo -e "\033[1;37mKernel version: \033[1;32mlinux-$(uname -r)\033[0m
\033[1;37mKernel source directory:\033[0m $SRC_DIR/linux-$(uname -r)/
\033[1;37mCompiled on: \033[0m$M_TIME\n
\033[1;37mPatches applied:\033[0m\n$(ls "$SRC_DIR"/linux-"$(uname -r)"/patches/)\n
\033[1;37mInstalled kernels \033[0m($KERNEL_DIR)\033[1;37m:\033[0m"
printf '%s\n' "${KERNELS//$KERNEL_DIR\/vmlinuz-}"
if [[ -n $UKI ]]; then
    echo -e "\n\033[1;37mUnified Kernel Images \033[0m($KERNEL_DIR)\033[1;37m:\033[0m"
    printf '%s\n' "${UKI//$KERNEL_DIR\/}"
fi
if [[ -n $(ls "$SRC_DIR"/backups/) ]]; then
    echo -e "\n\033[1;37mKernel backups \033[0m($SRC_DIR/backups)\033[1;37m:\033[0m"
    printf '%s\n' "${BACKUPS//$SRC_DIR\/backups\/}"
fi
echo
echo "Run with -h to see options."

