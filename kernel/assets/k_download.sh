#!/usr/bin/env bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    kernel [-d] args ...
#%
#% DESCRIPTION
#% This script is called by the [-d] flag and other functions in
#% order to download the kernel version passed to it. It is a
#% modified version of the script provided by kernel.org. It will
#% get the Linux kernel tarball and cryptographically verify it,
#% retrieving the PGP keys using the Web Key Directory (WKD)
#% protocol if they are not already in the keyring.
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

download() {
    case "$DOWNLOADER" in
        1)
            if [[ -n ${4} ]]; then
                wget -q ${1} -O ${3}
            else
                wget ${1} -O ${3}
            fi
            ;;
        2)
            if [[ -n ${4} ]]; then
                aria2c -q -x 3 -m 3 -d ${2} ${1}
            else
                aria2c -x 3 -m 3 -d ${2} ${1}
            fi
            ;;
        3)
            if [[ -n ${4} ]]; then
                curl -sL -o ${3} ${1}
            else
                curl -L -o ${3} ${1}
            fi
            ;;
    esac
}
local VER=${1}
if [[ -e $BUILD_DIR/linux-$1.tar.xz ]]; then
    echo "$BUILD_DIR/linux-${1}.tar.xz already exists"
    return
fi
echo -e "\n\033[1;37mDownloading \033[0;32mlinux-${VER}\033[0m"
local MAJOR="$(echo ${VER} | cut -d. -f1)"
if [[ ${MAJOR} -lt 3 ]]; then
    exoe "This script only supports kernel v3.x.x and above"
fi

if [[ ! -d ${BUILD_DIR} ]]; then
    exoe "${BUILD_DIR} does not exist"
fi

local TARGET="${BUILD_DIR}/linux-${VER}.tar.xz"
if [[ ! -x ${GPGBIN} ]]; then
    exoe "Could not find gpg in ${GPGBIN}"
fi
if [[ ! -x ${GPGVBIN} ]]; then
    exoe "Could not find gpgv in ${GPGVBIN}"
fi

local TMPDIR=$(mktemp -d ${BUILD_DIR}/linux-tarball-verify.XXXXXXXXX.untrusted)
echo -e "\033[1;37mUsing TMPDIR=\033[0;32m${TMPDIR}\033[0m"
if [[ -z ${USEKEYRING} ]]; then
    if [[ -z ${GNUPGHOME} ]]; then
        local GNUPGHOME="${TMPDIR}/gnupg"
    elif [[ ! -d ${GNUPGHOME} ]]; then
        echo "GNUPGHOME directory ${GNUPGHOME} does not exist"
        echo -n "Create it? [Y/n]"
        read YN
        if [[ ${YN} == 'n' ]]; then
            rm -rf ${TMPDIR}
            exoe "Exiting" 1
        fi
    fi
    mkdir -p -m 0700 ${GNUPGHOME}
    echo "Making sure we have all the necessary keys"
    ${GPGBIN} --batch --quiet \
        --homedir ${GNUPGHOME} \
        --auto-key-locate wkd \
        --locate-keys ${DEVKEYS} ${SHAKEYS}
    if [[ $? != "0" ]]; then
        rm -rf ${TMPDIR}
        exoe "Something went wrong fetching keys"
    fi
    local USEKEYRING=${TMPDIR}/keyring.gpg
    ${GPGBIN} --batch --export ${DEVKEYS} ${SHAKEYS} > ${USEKEYRING}
fi
local SHAKEYRING=${TMPDIR}/shakeyring.gpg
${GPGBIN} --batch \
    --no-default-keyring --keyring ${USEKEYRING} \
    --export ${SHAKEYS} > ${SHAKEYRING}
local DEVKEYRING=${TMPDIR}/devkeyring.gpg
${GPGBIN} --batch \
    --no-default-keyring --keyring ${USEKEYRING} \
    --export ${DEVKEYS} > ${DEVKEYRING}

local TXZ="$PROTO://cdn.kernel.org/pub/linux/kernel/v${MAJOR}.x/linux-${VER}.tar.xz"
local SIG="$PROTO://cdn.kernel.org/pub/linux/kernel/v${MAJOR}.x/linux-${VER}.tar.sign"
local SHA="$PROTO://www.kernel.org/pub/linux/kernel/v${MAJOR}.x/sha256sums.asc"

local SHAFILE=${TMPDIR}/sha256sums.asc
echo -e "\n\033[1;37mDownloading the checksums file for \033[0;32mlinux-${VER}\033[0m"
download "$SHA" "$TMPDIR" "$SHAFILE" "q" || { rm -rf ${TMPDIR}; exoe "Failed to download checksums file"; }
echo -e "\n\033[1;37mVerifying the checksums file\033[0m"
local COUNT=$(${GPGVBIN} --keyring=${SHAKEYRING} --status-fd=1 ${SHAFILE} \
        | grep -c -E '^\[GNUPG:\] (GOODSIG|VALIDSIG)')
if [[ ${COUNT} -lt 2 ]]; then
    rm -rf ${TMPDIR}
    exoe "FAILED to verify the sha256sums.asc file."
fi
local SHACHECK=${TMPDIR}/sha256sums.txt
grep "linux-${VER}.tar.xz" ${SHAFILE} > ${SHACHECK}

local SIGFILE=${TMPDIR}/linux-${VER}.tar.asc
echo -e "\n\033[1;37mDownloading the signature file for \033[0;32mlinux-${VER}\033[0m"
download "$SIG" "$TMPDIR" "$SIGFILE" "q" || { rm -rf ${TMPDIR}; exoe "Failed to download signature file"; }
[[ -e ${TMPDIR}/linux-${VER}.tar.sign ]] && mv "${TMPDIR}/linux-${VER}.tar.sign" "${SIGFILE}"
local TXZFILE=${TMPDIR}/linux-${VER}.tar.xz
echo -e "\n\033[1;37mDownloading the XZ tarball for \033[0;32mlinux-${VER}\033[0m"
download "$TXZ" "$TMPDIR" "$TXZFILE" || { rm -rf ${TMPDIR}; exoe "Failed to download tarball"; }
pushd ${TMPDIR} >/dev/null
echo -e "\n\033[1;37mVerifying checksum on \033[0;32mlinux-${VER}.tar.xz\033[0m"
if ! ${SHA256SUMBIN} -c ${SHACHECK}; then
    popd >/dev/null
    rm -rf ${TMPDIR}
    exoe "FAILED to verify the downloaded tarball checksum"
fi
popd >/dev/null
echo -e "\n\033[1;37mVerifying developer signature on the tarball\033[0m"
local COUNT=$(${XZBIN} -cd ${TXZFILE} \
        | ${GPGVBIN} --keyring=${DEVKEYRING} --status-fd=1 ${SIGFILE} - \
        | grep -c -E '^\[GNUPG:\] (GOODSIG|VALIDSIG)')
if [[ ${COUNT} -lt 2 ]]; then
    rm -rf ${TMPDIR}
    exoe "FAILED to verify the tarball!"
fi
mv -f ${TXZFILE} ${TARGET}
rm -rf ${TMPDIR}
echo -e "\n\033[1;37mSuccessfully downloaded and verified \033[0;32m${TARGET}\033[0m"
