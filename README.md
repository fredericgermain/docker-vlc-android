# how to build

This will build vlc-android on your host via a docker mount. To download & build latest commit in $PWD/root-vlc-android, just run.

    BUILDER_VOL=$PWD/root-vlc-android ./tests/build-vlc-android.sh

Then rebuild with:

    cd $PWD/root-vlc-android
    BUILDER_VOL=.. ../docker-vlc-android/utils/builder ./compile.sh    

Or just start an interactive session and launch ./compile.sh

# problems

## android-sdk license

This image was build with android-sdk, by auto accepting the licence. We would need a better way to control this, maybe by checking a file in $BUILDER_VOL using exported ANDROID_SDK_PACKAGES and ANDROID_SDK_LICENCES at start and ask the user to aggree to the license ?

Auto accepted android-sdk license :
License id: android-sdk-license-c81a61d9

## huge android-sdk and android-ndk
This makes the image really big.

On the other hand, this image is still generic enough to build other Android app by implementing new test in tests/.

Other image type would be to have the android-sdk/ndk on the host and mount it on launching countainer.
