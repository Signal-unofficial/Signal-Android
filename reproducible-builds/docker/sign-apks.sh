#!/bin/sh

# Retrieves and returns the keystore password from the user
# https://stackoverflow.com/a/3980713
getPassword() {
    printf >&2 'Enter Passphrase for keystore: '
    stty -echo
    read -r PASSWORD
    stty echo
    printf >&2 '\n'
    echo "${PASSWORD}"
}

# Signs the given APK
signApk() {
    PASSWORD=$1; shift
    KEYSTORE=$1; shift
    APK=$1; shift
    ALIAS=$1; shift

    apksigner sign --pass-encoding utf-8 --ks-pass "pass:${PASSWORD}" --ks "${KEYSTORE}" --ks-key-alias "${ALIAS}" "${APK}"
}

# Signing APKs in the current directory
KEYSTORE_PASSWORD="$(getPassword)"

for FILE in *; do 
    if [ -f "${FILE}" ]; then 
        echo "Signing ${FILE}" 
        signApk "${KEYSTORE_PASSWORD}" "${KEYSTORE_FILE}" "${FILE}" "${APK_ALIAS}"
    fi 
done
