#!/bin/bash

# Creating virtual machine
echo '===== Creating virtual device ====='
# shellcheck disable=SC2068 # Expanding $@ is intentional
avdmanager create avd \
    -n "${AVD_NAME}" \
    -k "${AVD_PACKAGE}" \
    -p "${AVD_PATH}" \
    $@

# Running VM
echo '===== Starting emulator ====='
# shellcheck disable=SC2086 # Expanding EMULATOR_ARGS is intentional
emulator ${EMULATOR_ARGS} &

# Waiting for the VM to start *and* boot
echo '===== Waiting for emulator ====='
adb wait-for-device

until [ "$(adb shell getprop sys.boot_completed)" = 1 ]; do
    sleep 1
done

# Installing APKs
echo '===== Installing APKs ====='
# shellcheck disable=SC2086 # Expanding APKS is intentional
adb install-multiple -t ${APKS} &

# Running VNC-like web server
echo '===== Running web server ====='
cd "/usr/ws-scrcpy/dist/" || {
    echo 'ws-scrcpy not installed correctly'
    exit
}
npm start

echo '===== Ready ====='
tail -f '/dev/null'
