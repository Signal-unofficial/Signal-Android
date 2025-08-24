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
#
# Syntax:
# signApk <KEYSTORE_PASSWORD> <KEYSTORE_FILENAME> <APK_FILENAME> <APK_ALIAS>
signApk() {
    PASSWORD=$1; shift

    echo "${PASSWORD}" | jarsigner -verbose -keystore "$@"
}

# Signing APKs in the current directory
KEYSTORE_PASSWORD="$(getPassword)"

for FILE in *; do 
    if [ -f "${FILE}" ]; then 
        echo "Signing ${FILE}" 
        signApk "${KEYSTORE_PASSWORD}" "${KEYSTORE_FILE}" "${FILE}" "${APK_ALIAS}"
    fi 
done
