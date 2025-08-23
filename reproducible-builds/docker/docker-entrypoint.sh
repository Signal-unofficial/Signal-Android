#!/bin/sh

# Hack to avoid the AVD being put in ${ANDROID_AVD_HOME}/.. for some reason
REAL_AVD_DIR=${ANDROID_AVD_HOME}/${AVD_NAME}

# Running the Android Emulator on a new virtual device
avdmanager --silent create avd \
    -n "${AVD_NAME}" \
    -k "${AVD_PACKAGE}" \
    -p "${REAL_AVD_DIR}" \
    $@
emulator \
    -avd "${AVD_NAME}" \
    -no-metrics \
    -noaudio \
    -no-boot-anim \
    -netdelay none \
    -no-window \
    -no-snapshot \
    &

# Installing APK(s)
adb install -t "${APK}"

# Forwarding ports
# https://developer.android.com/tools/adb#forwardports
adb forward tcp:8080 tcp:8080
adb forward udp:8080 udp:8080
adb forward tcp:8081 local:logd

# Blocking main process while emulator runs in background
tail -f '/dev/null'
