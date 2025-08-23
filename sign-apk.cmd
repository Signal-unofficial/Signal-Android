@echo off
setlocal

set APK_ALIAS=Signal
set KEYSTORE_FILE=dev.keystore

jarsigner -verbose -keystore "%KEYSTORE_FILE%" "%1" "%APK_ALIAS%"

endlocal
