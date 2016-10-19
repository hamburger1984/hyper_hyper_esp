#!/bin/sh

set -e

### wipe & restart
sudo ./luatool.py -w -r

### these are compiled to be able to "require(..)" them from init.lua
#sudo ./luatool.py --compile --src config.lua
#sudo ./luatool.py --compile --src i2c_helper.lua
#sudo ./luatool.py --compile --src mpu9250.lua
#sudo ./luatool.py --compile --src oled.lua

### ..don't compile for debugging..
sudo ./luatool.py --src config.lua
sudo ./luatool.py --src i2c_helper.lua
sudo ./luatool.py --src mpu9250.lua
sudo ./luatool.py --src oled.lua

### push init.lua & restart
sudo ./luatool.py --src init.lua -r
