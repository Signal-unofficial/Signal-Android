#!/bin/sh

# ADB will kill the connection if we try to pipe in the auth command,
# so the user will have to authenticate manually.
#
# **Should only be used locally**
# telnet sends plaintext, and is therefore insecure over a remote connection
telnet localhost "${ADB_PORT}"
