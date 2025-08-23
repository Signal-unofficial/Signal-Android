#!/bin/sh

# Hack to avoid the AVD being put in ${ANDROID_AVD_HOME}/.. for some reason
REAL_AVD_DIR=${ANDROID_AVD_HOME}/${AVD_NAME}

# Running the Android Emulator on a new virtual device
# shellcheck disable=SC2068 # Expanding $@ is intentional
avdmanager --silent create avd \
    -n "${AVD_NAME}" \
    -k "${AVD_PACKAGE}" \
    -p "${REAL_AVD_DIR}" \
    $@
# shellcheck disable=SC2086 # Expanding EMULATOR_ARGS is intentional
emulator \
    -avd "${AVD_NAME}" \
    -no-metrics \
    -no-window \
    -port "${EMULATOR_PORT}" \
    ${EMULATOR_ARGS} \
    &

echo 'INFO         | Waiting for the emulator to start...'
adb wait-for-device

echo 'INFO         | Waiting for the emulator to boot...'
while [ "$(adb shell getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

# Forwarding network traffic inspection port
# https://developer.android.com/tools/adb#forwardports
adb forward tcp:8081 local:logd

# Installing APKs
echo 'INFO         | Installing APKs...'
# shellcheck disable=SC2086 # Expanding APKS is intentional
adb install-multiple -t ${APKS}

# Blocking main process while emulator runs in background
echo 'INFO         | Ready!'
tail -f '/dev/null'
