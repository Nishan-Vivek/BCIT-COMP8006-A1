#!/usr/bin/env bash
DHCPSERVER="192.168.1.1"
SITE="www.bcit.ca"

#Verify DHCP server can be contacted.
echo "testing DHCP"
dhcping -s $DHCPSERVER

#Verify DNS
echo "testing DNS"
host bcit.ca

#Verify WWW
echo "testing SYN port 80"
hping3 $SITE -S -p 80 -c 1

echo "testing SYN port 443"
hping3 $SITE -S -p 443 -c 1



#Ver