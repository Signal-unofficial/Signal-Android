$APK_ALIAS="Signal"
$KEYSTORE_FILE="dev.keystore"

keytool -genkey -v -keystore "${KEYSTORE_FILE}" -alias "${APK_ALIAS}" -keyalg RSA -keysize 4096
