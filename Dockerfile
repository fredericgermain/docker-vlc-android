# to compile
#     docker build -t vlc-android-build:2.1.0.pre .
# to get a shell
#     docker run -it vlc-android-build:2.1.0.pre
# retreive apk 
#     id=$(docker create image-name)
#     docker cp $id:/root/vlc-android/vlc-android/build/outputs/apk/VLC-Android-2.1.0-ARMv7.apk .
#     docker rm -v $id

# https://github.com/webratio/docker/blob/master/java/8/Dockerfile
FROM ubuntu:trusty
#from debian:8.6
#from ubuntu:16.04

RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:webupd8team/java -y && \
    apt-get update -y && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y oracle-java8-installer && \
    apt-get remove software-properties-common -y && \
    apt-get autoremove -y && \
    apt-get clean
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV ANT_VERSION 1.9.7
RUN cd && \
    wget -q http://www.us.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    tar -xzf apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mv apache-ant-${ANT_VERSION} /opt/ant && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz
ENV ANT_HOME /opt/ant
ENV PATH ${PATH}:/opt/ant/bin

#FROM webratio/ant

# Installs i386 architecture required for running 32 bit Android tools
RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# Installs Android SDK
# http://stackoverflow.com/questions/38096225/automatically-accept-all-sdk-licences
#ENV ANDROID_SDK_FILENAME android-sdk_r23.0.2-linux.tgz
#ENV ANDROID_API_LEVELS android-15,android-16,android-17,android-18,android-19,android-20,android-21 
#ENV ANDROID_BUILD_TOOLS_VERSION 21.1.0
ENV ANDROID_SDK_FILENAME android-sdk_r24.3.4-linux.tgz
ENV ANDROID_SDK_URL http://dl.google.com/android/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-24 
ENV ANDROID_BUILD_TOOLS_VERSION 24.0.1
ENV ANDROID_SDK /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_SDK}/tools:${ANDROID_SDK}/platform-tools
RUN cd /opt && \
    wget -q ${ANDROID_SDK_URL} && \
    tar -xzf ${ANDROID_SDK_FILENAME} && \
    mkdir -p "${ANDROID_SDK}/licenses" && \
    echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "$ANDROID_SDK/licenses/android-sdk-license" && \
    echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "$ANDROID_SDK/licenses/android-sdk-preview-license" && \
    rm ${ANDROID_SDK_FILENAME} && \
    echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_API_LEVELS},build-tools-${ANDROID_BUILD_TOOLS_VERSION}


ENV ANDROID_NDK_VERSION r13
RUN cd /opt && \
    apt-get update -y && \
    apt-get install -y unzip && \
    wget -q https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    unzip android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip

#RUN git clone -b 2.0.x https://code.videolan.org/videolan/vlc-android.git 
RUN cd && \
    apt-get update -y && \
    apt-get install -y git && \
    git clone https://code.videolan.org/videolan/vlc-android.git

# tested version
RUN cd vlc-android && \
    git checkout ffbbb88081c 

#automatically get ANDROID_* vars setup when starting a new bash session
#COPY profile /root/.profile

WORKDIR /root/vlc-android
RUN apt-get install python pkg-config autoconf2.64 g++ -y
RUN ANDROID_SDK=${ANDROID_SDK} ANDROID_NDK=/opt/android-ndk-r13 PATH=$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools ./compile.sh


#CMD ["bash"]
