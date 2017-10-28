#!/bin/sh

set -e

read -p "CLEAN SDK? y [n] " clean;
case "$clean" in
    y|Y )
        pushd esp-open-sdk > /dev/null; \
            make clean; \
            popd > /dev/null;;
    * ) echo "keep existings builds.";;
esac

pushd esp-open-sdk > /dev/null; \
    git pull; \
    git submodule sync; \
    git submodule update --init; \
    make STANDALONE=y; \
    echo "--- done building esp-open-sdk ---"; \
    export PATH="$(pwd)/xtensa-lx106-elf/bin:$PATH"
    popd > /dev/null

echo "--- --- --- --- --- --- --- --- --- --- --- --- ---"
echo "PATH is \"$PATH\""
echo "--- --- --- --- --- --- --- --- --- --- --- --- ---"

# read -p "CLEAN Micropython? y [n] " clean;
# case "$clean" in
#     y|Y )
#         pushd micropython/firmware > /dev/null; \
#             make clean; \
#             popd > /dev/null;;
#     * ) echo "keep existings builds.";;
# esac

pushd micropython/firmware > /dev/null; \
    git pull; \
    git submodule sync; \
    git submodule update --init; \
    make -C mpy-cross; \
    pushd esp8266; \
    make axtls V=1; \
    make V=1; \
    popd > /dev/null; \
    echo "--- done building micropython ---"; \
    popd > /dev/null

read -p "Enter [FLASH] mode now!" -n1 -s
echo " Flashing.."
sudo python esptool.py --port /dev/ttyUSB0 \
        write_flash -fm dio -fs 32m \
        0x000000 micropython/firmware/esp8266/build/firmware-combined.bin \
        0x3fc000 esp-open-sdk/sdk/bin/esp_init_data_default.bin; \
    echo "--- done flashing ---"

read -p "Unplug & reconnect the devboard now" -n1 -s
echo " Connecting.."
sh connect_micropython.sh

# use precompiled images?!
# 1. https://micropython.org/download/
# 2. https://docs.micropython.org/en/latest/esp8266/esp8266/tutorial/intro.html

# for ENODEV & corrupt VFat, do:
# > import uos
# > import flashbdev
# > uos.VfsFat.mkfs(flashbdev.bdev)
