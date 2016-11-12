#
# Minimum Docker image to build VLC for android
#

FROM ubuntu:16.04
#from debian:8.6

MAINTAINER Frederic Germain <frederic.germain@gmail.com>

RUN apt-get update -y 

# https://github.com/webratio/docker/blob/master/java/8/Dockerfile
#RUN apt-get update -y && \
#    apt-get install -y software-properties-common && \
#    add-apt-repository ppa:webupd8team/java -y && \
#    apt-get update -y && \
#    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
#    apt-get install -y oracle-java8-installer && \
#    apt-get remove software-properties-common -y && \
#    apt-get autoremove -y && \
#    apt-get clean
#ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# Installs Android SDK
# http://stackoverflow.com/questions/38096225/automatically-accept-all-sdk-licences
COPY android-sdk-installer/accept-licenses /usr/bin
RUN apt-get install -y wget openjdk-8-jre-headless expect unzip \
    sudo \
    openjdk-8-jdk-headless git python pkg-config autoconf2.64 g++ 


#ENV ANDROID_SDK_FILENAME android-sdk_r23.0.2-linux.tgz
#ENV ANDROID_API_LEVELS android-15,android-16,android-17,android-18,android-19,android-20,android-21 
#ENV ANDROID_BUILD_TOOLS_VERSION 21.1.0
# need apt wget openjdk-8-jre-headless expect 
ARG ANDROID_SDK_FILENAME=android-sdk_r24.3.4-linux.tgz
ARG ANDROID_SDK_URL=http://dl.google.com/android/${ANDROID_SDK_FILENAME}
ARG ANDROID_API_LEVELS=android-24 
ARG ANDROID_BUILD_TOOLS_VERSION=24.0.1
ENV ANDROID_SDK_PACKAGES=tools,platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION},extra-android-m2repository
ENV ANDROID_SDK_LICENSES android-sdk-license-c81a61d9
ENV ANDROID_SDK /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools
RUN cd /opt && \
    wget -q ${ANDROID_SDK_URL} && \
    tar -xzf ${ANDROID_SDK_FILENAME} && \
    rm ${ANDROID_SDK_FILENAME} && \
    accept-licenses "android update sdk --no-ui -a --filter ${ANDROID_SDK_PACKAGES}" "${ANDROID_SDK_LICENSES}"

# need apt wget unzip 
ARG ANDROID_NDK_VERSION=r13
ENV ANDROID_NDK /opt/android-ndk-${ANDROID_NDK_VERSION}
RUN cd /opt && \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    unzip android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    rm android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

# All builds will be done by user builder
RUN mkdir -p /home/builder
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/vlc-android"]

# need apt sudo
COPY utils/docker_entrypoint.sh /root/docker_entrypoint.sh
ENTRYPOINT ["/root/docker_entrypoint.sh"]

# vlc-android compile need apt git python pkg-config autoconf2.64 g++ openjdk-8-jdk
# Work in the build directory
WORKDIR /vlc-android

