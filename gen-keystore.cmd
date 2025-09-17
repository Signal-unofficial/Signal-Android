@echo off
setlocal

set APK_ALIAS="Signal"
set KEYSTORE_FILE="./reproducible-builds/secrets/dev.keystore"

keytool -genkey -v -keystore %KEYSTORE_FILE% -alias %APK_ALIAS% -keyalg RSA -keysize 4096

endlocal
