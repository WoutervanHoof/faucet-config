#!/bin/sh
if [ -f /var/run/tcpdump.pid ]
then
        sudo kill `cat /var/run/tcpdump.pid`
        sudo echo tcpdump `cat /var/run/tcpdump.pid` killed.
        sudo rm -f /var/run/tcpdump.pid
fi
