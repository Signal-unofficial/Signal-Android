$APK_ALIAS="Signal"
$KEYSTORE_FILE="dev.keystore"

jarsigner -verbose -keystore "${KEYSTORE_FILE}" $args[0] "${APK_ALIAS}"
