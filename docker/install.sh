#!/bin/bash

MAKEMKV_URL="https://www.makemkv.com/download/"
MAKEMKV_VERSION="1.16.5"

set -ex

# Get the checksums - the checksum file is signed with their gpg key, which we
# fetch from the ubuntu keyserver
wget -O "checksum.sig" "${MAKEMKV_URL}/makemkv-sha-${MAKEMKV_VERSION}.txt"
export GNUPGHOME="$(mktemp -d)"
gpg --batch --keyserver keyserver.ubuntu.com --recv-keys 2ECF23305F1FC0B32001673394E3083A18042697
gpg --batch --decrypt --output checksum.txt checksum.sig
gpgconf --kill all
rm -rf $GNUPGHOME checksum.sig

# oss then bin according to https://forum.makemkv.com/forum/viewtopic.php?f=3&t=224
for target in makemkv-oss makemkv-bin; do
    wget "${MAKEMKV_URL}/${target}-${MAKEMKV_VERSION}.tar.gz"
    sha256sum -c --ignore-missing checksum.txt

    # extract
    mkdir -p "${target}"
    tar -zxf "${target}-${MAKEMKV_VERSION}.tar.gz" -C $target --strip-components=1
    cd $target

    # actions depending on the contents
    if [ -f configure ]; then
        ./configure --prefix="/usr/local"
    else
        # The makefile has this file as a target - we premake it to avoid
        # interacting with less
        mkdir -p tmp
        touch tmp/eula_accepted
    fi

    make -j$(nproc) PREFIX="/usr/local"
    make install PREFIX="/usr/local"

    cd ..
    rm -rf $target "${target}-${MAKEMKV_VERSION}.tar.gz"
done

rm -f checksum.txt
