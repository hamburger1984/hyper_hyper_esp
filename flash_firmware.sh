#!/bin/sh

read -p "Enter [FLASH] mode now!" -n1 -s
echo " Flashing.."
pushd esptool > /dev/null;\
    sudo python esptool.py --port /dev/ttyUSB0 \
        write_flash -fm dio -fs 32m \
        0x000000 ../nodemcu-master-17-modules-2016-09-02-12-19-39-integer.bin \
        0x3fc000 ../esp-open-sdk/sdk/bin/esp_init_data_default.bin; \
    echo "--- done flashing ---"; \
    popd > /dev/null
