#!/bin/sh

APK_ALIAS='Signal'
KEYSTORE_FILE='dev.keystore'

jarsigner -verbose -keystore "${KEYSTORE_FILE}" "$1" "${APK_ALIAS}"
