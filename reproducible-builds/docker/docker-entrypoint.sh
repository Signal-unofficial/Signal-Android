#!/bin/sh

# Creating virtual machine
echo '===== Creating virtual device ====='
# shellcheck disable=SC2068 # Expanding $@ is intentional
avdmanager --silent create avd \
    -n "${AVD_NAME}" \
    -k "${AVD_PACKAGE}" \
    -p "${AVD_PATH}" \
    $@

# Creating device screen
echo '===== Starting display ====='
# shellcheck disable=SC2086 # Expanding XVFB_ARGS is intentional
Xvfb ${XVFB_ARGS} &

echo '===== Waiting for display ====='

until xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; do
    sleep 1
done

# Creating window manager
openbox &

# Broadcasting the screen
echo '===== Starting virtual framebuffer ====='
# shellcheck disable=SC2086 # Expanding X11VNC_ARGS is intentional
x11vnc ${X11VNC_ARGS} &

# Running VNC server to expose the emulator to the host
echo '===== Starting VNC server ====='
# shellcheck disable=SC2086 # Expanding NOVNC_ARGS is intentional
'/usr/share/novnc/utils/launch.sh' ${NOVNC_ARGS} &

echo '===== Waiting for VNC server ====='

while [ "$(curl -s --head localhost:"${NOVNC_PORT}" | awk '/^HTTP/{print $2}')" != '200' ]; do
    sleep 1
done

# Emulating device
echo '===== Starting emulator ====='
# shellcheck disable=SC2086 # Expanding EMULATOR_ARGS is intentional
emulator ${EMULATOR_ARGS} &

# Waiting for the emulator to start *and* boot
echo '===== Waiting for emulator ====='
adb wait-for-device

while [ "$(adb shell getprop sys.boot_completed)" != 1 ]; do
    sleep 1
done

# Installing APKs
echo '===== Installing APKs ====='
# shellcheck disable=SC2086 # Expanding APKS is intentional
adb install-multiple -t ${APKS}

echo '===== Ready ====='
tail -f '/dev/null'
