# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n

export ANDROID_SDK=/opt/android-sdk-linux
export ANDROID_NDK=/opt/android-ndk-r13
export PATH=$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools 
