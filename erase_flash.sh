#!/bin/sh

set -e

read -p "Enter [FLASH] mode now!" -n1 -s
echo " Erasing.."
pushd esptool > /dev/null; \
    sudo python esptool.py --port /dev/ttyUSB0 erase_flash; \
    echo "--- done erasing --"; \
    popd > /dev/null
