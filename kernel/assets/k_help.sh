#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-h]
#%
#% DESCRIPTION
#% This script is called by the [-h] flag and displays a help
#% menu with a list of options.
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

cat <<EOF
Usage: kernel [-flag] [OPTIONAL_ARG]
Custom Kernel Manager.
Author: Jason McGuire

-d) Downloads specified kernel version to $BUILD_DIR (Requires kernel version as argument.)
    Ex. kernel -d 5.15.5

-i) Download, compile and install the kernel version passed as an argument.
    Ex. kernel -i 5.15.5

-b) Create a .tar.gz archive of the kernel source directory. (Requires kernel version as argument.)
    Ex. kernel -b 5.15.5-NAME

-m) Modify kernel config and optionally recompile and install kernel (Requires kernel version as argument.)
    Ex. kernel -m 5.15.5-NAME

-r) Remove a kernel from system. (Requires kernel version as argument.)
    Ex. kernel -r 5.15.5-NAME

-a) Restore a kernel that was previously archived. (Requires kernel version as argument.)
    Ex. kernel -a 5.15.5-NAME

-c) View the kernel changelog for the version passed as an argument.
    Ex. kernel -c 5.15.5

-p) Dump a directory containing the patches listed in patchfile given (used for testing).
    Ex. kernel -p

-u) Update the current kernel to the latest stable on kernel.org.
    Ex. kernel -u

-n) Create a new kernel. Select from a menu of the newest kernels on kernel.org
    Ex. kernel -n

-h) Show this dialogue.
    Ex. kernel -h
EOF
