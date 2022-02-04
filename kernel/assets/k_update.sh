#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-u]
#%
#% DESCRIPTION
#% This script is called by the [-u] flag and downloads the
#% finger_banner from kernel.org and compares the latest stable
#% version with the version obtained from uname -r. If the newest
#% stable is newer than the currently installed version it will
#% allow you to update to the newer kernel by passing the new
#% version to k_prepare for download and installation.
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

isUpdate() {
    IFS='.' read -r -a NEW <<< "$1"
    IFS='.' read -r -a INSTALLED <<< "$2"
    if [[ ${NEW[1]} -gt ${INSTALLED[1]} ]]; then
        return 0
    elif [[ ${NEW[2]} -le ${INSTALLED[2]} ]]; then
        return 1
    else
        return 0
    fi
}

echo -e "\033[1;37mGetting latest kernel version...\033[0m"
case $DOWNLOADER in
    1)
        local VERS=$(wget -P "$RUN_DIR" "$PROTO"://www.kernel.org/finger_banner > /dev/null 2>&1 && awk '{print $NF}' "$RUN_DIR"/finger_banner | head -n 1 && rm -f "$RUN_DIR"/finger_banner*)
        ;;
    2)
        local VERS=$(aria2c -q -x 3 -m 3 -d "$RUN_DIR" "$PROTO"://www.kernel.org/finger_banner > /dev/null 2>&1 && awk '{print $NF}' "$RUN_DIR"/finger_banner | head -n 1 && rm -f "$RUN_DIR"/finger_banner*)
        ;;
    3)
        local VERS=$(curl -o "$RUN_DIR"/finger_banner "$PROTO"://www.kernel.org/finger_banner > /dev/null 2>&1 && awk '{print $NF}' "$RUN_DIR"/finger_banner | head -n 1 && rm -f "$RUN_DIR"/finger_banner*)
        ;;
esac
local CURRENT_VERS=$(uname -r | awk -F "-" '{print $1}')

if [[ $(awk -F "." '{print NF}' <<< "$VERS") -lt 3 ]]; then
    local MVERS=${VERS}.0
else
    local MVERS=${VERS}
fi
if isUpdate "$MVERS" "$CURRENT_VERS"; then
    echo -e "\033[1;32m$CURRENT_VERS\033[0m -> \033[1;32m$VERS\n"
    read -t 10 -n 1 -p $'\033[1;37mView kernel changelog? \033[0m[y/N]: ' REPLY
    case ${REPLY:-N} in
        [yY])
            source "$k_path"/assets/k_cl.sh "$VERS"
            ;;
        *)
            echo -e "\nskipping"
            ;;
    esac
    read -t 10 -n 1 -p $'\n\033[1;37mWould you like to update? \033[0m[y/N]: ' REPLY
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit
    fi
    source "$k_path"/assets/k_prepare.sh "$VERS"
    if [[ -f $SRC_DIR/linux-$VERS.tar.xz ]]; then
        echo -e "\n\033[1;37mCleaning up\033[0m\n"
        rm -rf "$SRC_DIR"/linux-"${VERS}".tar.xz
    fi
else
    echo -e "\033[1;37mNewest stable version (\033[1;32m$CURRENT_VERS\033[1;37m) is already installed\033[0m"
    rm -rf "$RUN_DIR"/*.html
    exit
fi
