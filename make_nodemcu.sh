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

read -p "CLEAN Nodemcu? y [n] " clean;
case "$clean" in
    y|Y )
        pushd nodemcu/firmware > /dev/null; \
            make clean; \
            popd > /dev/null;;
    * ) echo "keep existings builds.";;
esac

read -p "Edit modules to build now? y [n] " configure;
case "$configure" in
    y|Y )
        editor=$EDITOR
        [ -z $editor ] && which nvim && editor=nvim
        [ -z $editor ] && which vim && editor=vim
        [ -z $editor ] && which nano && editor=nano
        [ -z $editor ] && echo "No editor found"
        $editor nodemcu/firmware/app/include/user_modules.h;;
    * ) ;;
esac

pushd nodemcu/firmware > /dev/null; \
    git pull; \
    git submodule sync; \
    git submodule update --init; \
    # float build
    # make all; \
    # integer only build
    make EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" all; \
    srec_cat -output bin/combined.bin -binary bin/0x00000.bin -binary -fill 0xff 0x00000 0x10000 bin/0x10000.bin -binary -offset 0x10000; \
    cp app/mapfile bin/combined.map; \
    echo "--- done build nodemcu-firmware ---"; \
    popd > /dev/null

read -p "Enter [FLASH] mode now!" -n1 -s
echo " Flashing.."
pushd esptool > /dev/null; \
    sudo python esptool.py --port /dev/ttyUSB0 \
        write_flash -fm dio -fs 32m \
        0x000000 ../nodemcu/firmware/bin/combined.bin \
        0x3fc000 ../esp-open-sdk/sdk/bin/esp_init_data_default.bin; \
    # sudo python esptool.py --port /dev/ttyUSB0 \
    #     write_flash -fm dio -fs 32m \
    #     0x000000 ../nodemcu/firmware/bin/0x00000.bin \
    #     0x010000 ../nodemcu/firmware/bin/0x10000.bin \
    #     0x3fc000 ../esp-open-sdk/sdk/bin/esp_init_data_default.bin; \
    echo "--- done flashing ---"; \
    popd > /dev/null

read -p "Unplug & reconnect the devboard now" -n1 -s
echo " Connecting.."
sh connect_nodemcu.sh

# use precompiled images?!
# see: https://nodemcu-build.com/
