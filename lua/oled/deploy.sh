#!/bin/sh

set -e

### wipe & restart
sudo ./luatool.py -w -r

### these are compiled to be able to "require(..)" them from init.lua
sudo ./luatool.py --compile --src app.lua


### push init.lua & restart
sudo ./luatool.py --src init.lua -r
