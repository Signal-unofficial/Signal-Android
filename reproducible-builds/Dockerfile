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

ENV ANDROID_COMMAND_LINE_TOOLS_FILENAME=commandlinetools-linux-10406996_latest.zip
ENV ANDROID_COMMAND_LINE_TOOLS_HASH=sha256:8919e8752979db73d8321e9babe2caedcc393750817c1a5f56c128ec442fb540
ENV ANDROID_API_LEVELS=android-35
ENV ANDROID_BUILD_TOOLS_VERSION=35.0.0

ENV ANDROID_HOME=/usr/local/android-sdk-linux
ENV PATH=${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/cmdline-tools/bin

VOLUME [ "/project" ]

WORKDIR ${ANDROID_HOME}/..
ADD --checksum=${ANDROID_COMMAND_LINE_TOOLS_HASH} "https://dl.google.com/android/repository/${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" "./"
RUN \
    unzip "./${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" -d './android-sdk-linux/' && \
    rm "./${ANDROID_COMMAND_LINE_TOOLS_FILENAME}" && \
    apt-get remove -y unzip - && \
    yes | sdkmanager --update --sdk_root="${ANDROID_HOME}" && \
    yes | sdkmanager \
        --sdk_root="${ANDROID_HOME}" \
        "platforms;${ANDROID_API_LEVELS}" \
        "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
        "extras;google;m2repository" \
        "extras;android;m2repository" \
        "extras;google;google_play_services" \
        "ndk;28.0.13004108" \
        "cmake;3.22.1" && \
    yes | sdkmanager --licenses --sdk_root="${ANDROID_HOME}" && \
    rm -rf ${ANDROID_HOME}/tools && \
    git config --global --add safe.directory /project
