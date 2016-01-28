#!/usr/bin/env bash
IPADDR="192.168.1.30"


#Verify WWW
echo "testing SYN port 80"
hping3 $IPADDR -S -p 80 -c 1

echo "testing SYN port 443"
hping3 $IPADDR -S -p 443 -c 1


