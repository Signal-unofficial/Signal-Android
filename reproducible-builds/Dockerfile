ARG UBUNTU=ubuntu:jammy-20230624@sha256:b060fffe8e1561c9c3e6dea6db487b900100fc26830b9ea2ec966c151ab4c020

# Bundles the project
FROM ${UBUNTU} AS build

WORKDIR /etc/apt/
RUN [ "mv", "./sources.list", "./sources.list.old" ]
COPY [ "./docker/apt.conf", "./docker/sources.list", "/etc/apt/" ]

# Bit of a chicken-and-egg problem.
# Ubuntu needs the ca-certificates package before it'll trust our mirror.
# But we can't install it because it doesn't trust our mirror!
# To resolve, we temporarily use the original source list.
RUN \
    apt-get update -o 'Dir::Etc::sourcelist=./sources.list.old' && \
    apt-get install -o 'Dir::Etc::sourcelist=./sources.list.old' -y ca-certificates && \
    # Back to normal, using our mirror.
    apt-get update && \
    apt-get install -y git openjdk-17-jdk unzip && \
    apt-get clean

ARG ANDROID_COMMAND_LINE_TOOLS_FILENAME=commandlinetools-linux-10406996_latest.zip
ARG ANDROID_COMMAND_LINE_TOOLS_HASH=sha256:8919e8752979db73d8321e9babe2caedcc393750817c1a5f56c128ec442fb540
ARG ANDROID_API_LEVELS=android-35
ARG ANDROID_BUILD_TOOLS_VERSION=35.0.0

ENV ANDROID_SDK_ROOT=/usr/local/android-sdk-linux
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/bin:${ANDROID_SDK_ROOT}/emulator

# Used to qualify the type of Android Virtual Device (AVD) to create
ENV AVD_PACKAGE="system-images;android-35;google_apis;x86_64"

VOLUME [ "/project" ]

WORKDIR ${ANDROID_SDK_ROOT}
ADD --checksum=${ANDROID_COMMAND_LINE_TOOLS_HASH} \
    "https://dl.google.com/android/repository/${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" \
    './'
RUN \
    unzip "./${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" -d ${ANDROID_SDK_ROOT} && \
    rm "./${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" && \
    apt-get remove -y unzip - && \
    yes | sdkmanager --update && \
    yes | sdkmanager \
        "platforms;${ANDROID_API_LEVELS}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "extras;google;m2repository" \
        "extras;android;m2repository" \
        "extras;google;google_play_services" \
        "ndk;28.0.13004108" \
        "cmake;3.22.1" \
        "platform-tools" \
        "emulator" \
        "${AVD_PACKAGE}" && \
    yes | sdkmanager --licenses && \
    rm -rf ${ANDROID_SDK_ROOT}/tools && \
    git config --global --add safe.directory /project

WORKDIR /project/
ENTRYPOINT [ "./gradlew" ]

# OS-specific bundle (smaller)
CMD [ "bundlePlayProdRelease" ]

# Universal bundle (larger)
# CMD [ "assembleWebsiteProdRelease" ]

# Packages the bundle into APKs
FROM build AS package

ARG BUNDLETOOL_VERSION=1.18.1
ARG BUNDLETOOL_HASH=sha256:675786493983787ffa11550bdb7c0715679a44e1643f3ff980a529e9c822595c
ADD --checksum=${BUNDLETOOL_HASH} \
    "https://github.com/google/bundletool/releases/download/${BUNDLETOOL_VERSION}/bundletool-all-${BUNDLETOOL_VERSION}.jar" \
    '/usr/local/bin/bundletool.jar'

WORKDIR /project/
ENTRYPOINT [ \
    "java", "-jar", "/usr/local/bin/bundletool.jar", \
    "build-apks", \
    "--bundle=./bundle/playProdRelease/Signal-Android-play-prod-release.aab", \
    "--output-format=DIRECTORY", \
    "--output=apks" \
]

# Installs the APKs on an emulator
FROM build AS emulate

WORKDIR /project/
COPY [ "./docker/docker-entrypoint.sh", "/usr/local/bin/docker-entrypoint.sh" ]

ENV APK=./base-master.apk

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]
EXPOSE 8080/tcp 8080/udp 8081/tcp

# Args are sent to avdmanager to create the AVD to emulate
ENV ANDROID_AVD_HOME=/root/.android/avd
ENV AVD_NAME=test-device
CMD [ "-d", "desktop_large" ]
