DOCKER = docker
IMAGE = fredericgermain/builder-vlc-android

all: image

licences:
	mkdir -p "${ANDROID_SDK}/licenses"
	echo -e "\n8933bad161af4178b1185d1a37fbf41ea5269c55" > "${ANDROID_SDK}/licenses/android-sdk-license"
	echo -e "\n84831b9409646a918e30573bab4c9c91346d8abd" > "${ANDROID_SDK}/licenses/android-sdk-preview-license"

image: Dockerfile
	$(DOCKER) build -t $(IMAGE) .
	#$(DOCKER) build -t $(IMAGE) -v lic:/opt/android-sdk-linux/licenses .

.PHONY: all
