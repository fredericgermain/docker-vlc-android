#!/bin/bash
set -e

# This script designed to be used a docker ENTRYPOINT "workaround" missing docker
# feature discussed in docker/docker#7198, allow to have executable in the docker
# container manipulating files in the shared volume owned by the USER_ID:GROUP_ID.
#
# It creates a user named `builder` with selected USER_ID and GROUP_ID (or
# 1000 if not specified).

# Example:
#
#  docker run -ti -e USER_ID=$(id -u) -e GROUP_ID=$(id -g) imagename bash
#

# Reasonable defaults if no USER_ID/GROUP_ID environment variables are set.
if [ -z ${USER_ID+x} ]; then USER_ID=1000; fi
if [ -z ${GROUP_ID+x} ]; then GROUP_ID=1000; fi

msg="docker_entrypoint: Creating user UID/GID [$USER_ID/$GROUP_ID]" && echo $msg
groupadd -g $GROUP_ID -r builder && \
useradd -u $USER_ID --create-home -r -g builder builder
usermod -aG sudo builder
echo "$msg - done"

msg="docker_entrypoint: Copying .bash_aliases, .gitconfig and .ssh/config to new user home" && echo $msg
cp /root/.bash_aliases /home/builder/.bash_aliases && \
chown builder:builder /home/builder/.bash_aliases && \
cp /root/.gitconfig /home/builder/.gitconfig && \
chown builder:builder /home/builder/.gitconfig && \
mkdir -p /home/builder/.ssh && \
cp /root/.ssh/config /home/builder/.ssh/config && \
chown builder:builder -R /home/builder/.ssh &&
echo "$msg - done"

msg="docker_entrypoint: Creating /tmp/ccache and /vlc-android /opt/android-sdk-linux/licenses directory" && echo $msg
mkdir -p /tmp/ccache /vlc-android /opt/android-sdk-linux/licenses
chown builder:builder /tmp/ccache /vlc-android /opt/android-sdk-linux/licenses
echo "$msg - done"

echo ""

# Default to 'bash' if no arguments are provided
args="$@"
if [ -z "$args" ]; then
  args="bash"
fi

export ANDROID_SDK=/opt/android-sdk-linux
export ANDROID_NDK=/opt/android-ndk-r13
export PATH=$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools 

# Execute command as `builder` user
export HOME=/home/builder
exec sudo -u builder $args
# ~/.profile: executed by Bourne-compatible login shells.

