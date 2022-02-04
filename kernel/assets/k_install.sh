#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    Not called directly.
#%
#% DESCRIPTION
#% This script is called by other functions to install the
#% compiled kernel. It first copies the kernel source directory
#% containing the newly compiled bzImage from $BUILD_DIR to
#% $SRC_DIR. There it will install modules and cp the bzImage
#% to $KERNEL_DIR.  Then it will create the initramfs unless
#% $INITRD is set to none in kernel.conf. If using mkinitcpio it
#% will create the .preset file in /etc/mkinitcpio.d/ from
#% existing files. If any part of the script fails it will
#% cleanup the files it created.
#%
#% OPTIONS
#% Recieves kernel version as a parameter $1.
#% Recieves $BUILD_DIR as a parameter $2.
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
    if ((${#K_FILES[@]})); then
        echo "Cleaning up..."
        for file in "${K_FILES[@]}"; do
            rm -rf "$file"
        done
    fi
    exit 1
}
if [[ -f /home/$SUDO_USER/.config/kernel/kernel.conf ]]; then
    source /home/"$SUDO_USER"/.config/kernel/kernel.conf
else
    exoe "Can't find configuration file"
fi
BUILD_DIR="$2"
echo -e "\033[1;37mInstalling linux-$1\033[0m"
[[ -d $SRC_DIR/linux-${1} ]] && rm -rf "$SRC_DIR"/linux-"$1"
mv "$BUILD_DIR"/linux-"${1}" "$SRC_DIR"/ || exoe "Cannot find $BUILD_DIR/linux-${1}"
cd "$SRC_DIR"/linux-"${1}" || exoe "Can't find $SRC_DIR/linux-$1"
K_FILES+=( "$SRC_DIR/linux-${1}" )
install -v "$SRC_DIR"/linux-"${1}"/arch/x86_64/boot/bzImage "$KERNEL_DIR"/vmlinuz-linux-"${1}"
K_FILES+=( "$KERNEL_DIR/vmlinuz-linux-${1}" )
echo -e "\n\033[1;37mInstalling modules\033[0m\n"
make modules_install
K_FILES+=( "/usr/lib/modules/${1}" )
case $INITRD in
    mkinitcpio)
        echo -e "\n\033[1;37mGenerating initramfs\033[0m\n"
        cd /etc/mkinitcpio.d/ || exoe "mkinitcpio preset directory not found"
        cp linux-"$(uname -r)".preset linux-"${1}".preset
        K_FILES+=( "/etc/mkinitcpio.d/linux-${1}.preset" )
        sed -i "s/$(uname -r)/${1}/g" linux-"${1}".preset
        mkinitcpio -p linux-"${1}"
        for file in "$KERNEL_DIR"/initramfs-"${1}"*; do
            K_FILES+=( "$file" )
        done
        ;;
    dracut)
        echo -e "\n\033[1;37mGenerating initramfs\033[0m\n"
        dracut --kver "${1}" --hostonly --no-hostonly-cmdline "$KERNEL_DIR"/initramfs-linux-"${1}".img
        for file in "$KERNEL_DIR"/initramfs-"${1}"*; do
            K_FILES+=( "$file" )
        done
        ;;
    none)
        echo "Skipping initramfs creation"
esac
echo -e "\n\033[1;37mThe following files have been installed to the system:\n"
for file in "${K_FILES[@]}"; do
    echo -e "$file"
done
if [[ -e /home/"$SUDO_USER"/.config/kernel/hooks ]]; then
    read -n 1 -r -p $'\n\033[1;37mRun post-installation hooks? \033[0m[y/N] ' REPLY
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        source /home/"$SUDO_USER"/.config/kernel/hooks
    fi
fi
echo -e "\nBe sure to update the bootloader.\nGrub: \033[0;32msudo grub-mkconfig -o $KERNEL_DIR/grub/grub.cfg\033[0m\nSystemd-boot: Edit necessary config files."
