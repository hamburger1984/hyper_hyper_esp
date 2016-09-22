#!/bin/sh

reset
echo "ESP8266 -- Starting screen session to /dev/ttyUSB0"
echo " * use C-a, d to detach"
echo " * node.restart() if you didn't powercycle"
echo " * file.format() on first boot after flashing"
read -p " - press a key - " -n1 -s

# sudo screen /dev/ttyUSB0 9600
sudo screen /dev/ttyUSB0 115200
