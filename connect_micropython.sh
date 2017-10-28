#!/bin/sh

reset
echo "ESP8266 -- Starting screen session to /dev/ttyUSB0"
echo " * use C-a, d to detach"
read -p " - press a key - " -n1 -s

sudo screen /dev/ttyUSB0 115200
