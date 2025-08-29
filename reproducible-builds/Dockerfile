ARG BASE_IMAGE=ubuntu:jammy-20230624@sha256:b060fffe8e1561c9c3e6dea6db487b900100fc26830b9ea2ec966c151ab4c020

FROM ${BASE_IMAGE} AS base

COPY [ "./docker/apt.conf", "/etc/apt/" ]

# Bundles the project
FROM ${BASE_IMAGE} AS build

RUN \
    apt-get update -qq && \
    apt-get install -yqq git openjdk-17-jdk unzip && \
    apt-get clean -qq

# Installing Android SDK 12.0
ARG ANDROID_COMMAND_LINE_TOOLS_FILENAME=commandlinetools-linux-11076708_latest.zip
ARG ANDROID_COMMAND_LINE_TOOLS_HASH=sha256:2d2d50857e4eb553af5a6dc3ad507a17adf43d115264b1afc116f95c92e5e258

ENV ANDROID_HOME=/root/Android/Sdk

WORKDIR ${ANDROID_HOME}
ADD --checksum=${ANDROID_COMMAND_LINE_TOOLS_HASH} \
    "https://dl.google.com/android/repository/${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" \
    './'
RUN \
    unzip "./${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" -d "${ANDROID_HOME}/cmdline-tools" && \
    rm "./${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" && \
    apt-get remove -yqq unzip

# Hack to put the SDK in the expected location
WORKDIR ${ANDROID_HOME}/cmdline-tools
RUN mv "./cmdline-tools" "./latest"
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/latest/bin

ARG ANDROID_API_LEVELS=android-35
ARG ANDROID_BUILD_TOOLS_VERSION=35.0.0

# Installing dependencies
RUN \
    yes | sdkmanager \
        "platforms;${ANDROID_API_LEVELS}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "extras;google;m2repository" \
        "extras;android;m2repository" \
        "extras;google;google_play_services" \
        "ndk;28.0.13004108" \
        "cmake;3.22.1" && \
    yes | sdkmanager --licenses && \
    rm -rf ${ANDROID_HOME}/tools

VOLUME [ "/project" ]
RUN \
    git config --global --add safe.directory /project && \
    apt-get remove -yqq git && \
    apt-get clean -qq

ENV PATH=${PATH}:${ANDROID_HOME}/build-tools/${ANDROID_BUILD_TOOLS_VERSION}:${ANDROID_HOME}/emulator

# Bundling project
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

FROM build AS sign

COPY [ "./docker/sign-apks.sh", "/usr/local/bin/" ]

ENV APK_ALIAS='Signal'
ENV KEYSTORE_FILE='/run/secrets/dev.keystore'

WORKDIR /project/
ENTRYPOINT [ "/usr/local/bin/sign-apks.sh" ]

# Installs the APKs on an emulator
FROM build AS emulate

WORKDIR /etc/apt/
RUN \
    yes | sdkmanager "platform-tools" "emulator" && \
    yes | sdkmanager --licenses && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yqq \
        bridge-utils \
        expect \
        gnome-core \
        libvirt-clients \
        libvirt-daemon-system \
        pulseaudio \
        qemu-kvm \
        telnet \
        tightvncserver \
        xfce4 \
        xfonts-base && \
    apt-get clean -qq

# Used to qualify the type of Android Virtual Device (AVD) to emulate.
#
# ARM-based system images require the host platform to also be ARM-based.
# The same also applies to x86.
#
# Due to the necessity of KVM support, WSL1 isn't supported because it imitates
# a Linux kernel. Support would require either installing a real Linux kernel
# or adding -no-accel to EMULATOR_ARGS.
#
ENV AVD_PACKAGE="system-images;android-35;google_apis;x86_64"

RUN \
    yes | sdkmanager "${AVD_PACKAGE}" && \
    yes | sdkmanager --licenses

WORKDIR /project/
COPY [ \
    "./docker/docker-entrypoint.sh", \
    "./docker/vncserver.exp", \
    "./docker/console.exp", \
    "/usr/local/bin/" \
]

RUN [ "chmod", "+x", "/usr/local/bin/vncserver.exp" ]

ENTRYPOINT [ "/usr/local/bin/docker-entrypoint.sh" ]

ENV ANDROID_EMU_USE_SYSTEM_LIBS=1
ENV USER='root'
ENV HOME="/${USER}"
ARG DISPLAY_INDEX=':0'
ENV DISPLAY="${DISPLAY_INDEX}.0"
ENV XRDB_ARGS=" \
    ${HOME}/.Xresources \
    xsetroot \
    -solid grey \
    vncconfig \
    -iconic \
    "
ENV VNCSERVER_PASSWORDFILE='/run/secrets/vnc_passwd.conf'
ARG VNC_PORT='5900'
ENV VNCSERVER_ARGS=" \
    "${DISPLAY_INDEX}" \
    -httpport "${VNC_PORT}" \
    -geometry 1080x1920 \
    -depth 24 \
    # nologo \
    "
ENV ANDROID_AVD_HOME="${HOME}/.android/avd"
# If set to ${ANDROID_AVD_HOME}, the AVDs will actually be
# put in ${ANDROID_AVD_HOME}/.. instead for some reason
ENV AVD_PATH="${ANDROID_AVD_HOME}/devices"
ENV AVD_NAME='test-device'
ENV ADB_PORT='5554'
ENV EMULATOR_ARGS=" \
    # Required:
    -avd "${AVD_NAME}" \
    -port "${ADB_PORT}" \
    -no-qt \
    -gpu swiftshader_indirect \
    # Configurable:
    -no-metrics \
    -no-snapshot \
    -wipe-data \
    -no-boot-anim \
    -netdelay none \
    -no-audio \
    -no-passive-gps \
    -no-location-ui \
    "
ENV APKS=" \
    base-master.apk \
    base-xxhdpi.apk \
    base-x86_64.apk \
    "
# avdmanager args
CMD [ \
    "-f", \
    "-d", "desktop_large" \
]

# ADB_PORT is only accessible on localhost
EXPOSE "${VNC_PORT}"
