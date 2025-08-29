#!/bin/bash

SCRIPT_DIR="$(dirname "$0")"

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

# Exposing emulator to the host
# https://stackoverflow.com/a/57651203
echo '===== Starting VNC server ====='
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
startxfce4 &
# shellcheck disable=SC2086 # Expanding XRDB_ARGS is intentional
[ -x /etc/vnc/xstartup ] \
    && exec /etc/vnc/xstartup [ -r "${HOME}/.Xresources" ] \
    && xrdb ${XRDB_ARGS} &
mkdir -p "${HOME}/.vnc"
# shellcheck disable=SC2086 # Expanding VNCSERVER_ARGS is intentional
expect "${SCRIPT_DIR}/vncserver.exp" "${VNCSERVER_PASSWORDFILE}" "${VNCSERVER_ARGS[@]}"

echo '===== Done ====='
tail -f '/dev/null'
