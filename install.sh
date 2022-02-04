#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#%    ./install.sh
#%
#% DESCRIPTION
#% Install script for custom-kernel-manager.
#%
#% OPTIONS
#% None
#%
#================================================================
#- IMPLEMENTATION
#-    version         custom-kernel-manager 1.0
#-    author          Jason McGuire
#-    email           haximus84@protonmail.com
#-    copyright       None
#-    license         MIT
#-
#================================================================
# END_OF_HEADER
#================================================================

[[ ! -d ~/.local/bin ]] && mkdir -p ~/.local/bin
cp -r kernel ~/.local/bin/kernel-manager
ln -s ~/.local/bin/kernel-manager/kernel.sh ~/.local/bin/kernel
[[ ! -d ~/.config/kernel/ ]] && mkdir -p ~/.config/kernel
cp kernel.conf ~/.config/kernel/
echo -e "\033[1;32mBe sure to add ~/.local/bin/ to PATH\n Edit ~/.config/kernel/kernel.conf if necessary\033[0m"
