#!/bin/sh
FILE="/home/wouter/tcpdump.pid"
if [ -f "$FILE" ]
then
        sudo kill `cat "$FILE"`
        sudo echo tcpdump `cat "$FILE"` killed.
        sudo rm -f "$FILE"
fi
