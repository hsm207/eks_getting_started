#!/bin/bash

# from https://unix.stackexchange.com/questions/69314/automated-ssh-keygen-without-passphrase-how

cat /dev/zero |
    ssh-keygen -q  -N ""

ls -la ~/.ssh