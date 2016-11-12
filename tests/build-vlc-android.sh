#!/bin/bash
#
# Test script file that maps itself into a docker container and runs
#
# Example invocation:
#
# $ BUILDER_VOL=$PWD/build ./build-vlc-android.sh
#
set -ex

if [ "$1" = "docker" ]; then
#    cpus=$(grep ^processor /proc/cpuinfo | wc -l)

# is it possible to make ccache work with vlc build ?
#    ccache -M 10G

#git clone -b 2.0.x https://code.videolan.org/videolan/vlc-android.git 
     if [ ! -d .git ]; then
       git clone https://code.videolan.org/videolan/vlc-android.git .
     fi

    ./compile.sh
else
    BUILDER_url="https://raw.githubusercontent.com/fredericgermain/docker-vlc-android/master/utils/builder"
    # -i to load .bashrc
    args="bash -i run.sh docker"
    export BUILDER_EXTRA_ARGS="-v $(cd $(dirname $0) && pwd -P)/$(basename $0):/usr/local/bin/run.sh:ro"
    export BUILDER_IMAGE="fredericgermain/docker-vlc-android"

    #
    # Try to invoke the builder wrapper with the following priority:
    #
    # 1. If BUILDER_BIN is set, use that
    # 2. If builder is found in the shell $PATH
    # 3. Grab it from the web
    #
    if [ -n "$BUILDER_BIN" ]; then
        $BUILDER_BIN $args
    elif [ -x "../utils/builder" ]; then
        ../utils/builder $args
    elif [ -n "$(type -P builder)" ]; then
        builder $args
    else
        if [ -n "$(type -P curl)" ]; then
            bash <(curl -s $BUILDER_url) $args
        elif [ -n "$(type -P wget)" ]; then
            bash <(wget -q $BUILDER_url -O -) $args
        else
            echo "Unable to run the builder binary"
        fi
    fi
fi
