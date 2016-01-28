#!/usr/bin/env bash

#Symbolic Constants as specified in Linux Firewalls 3rd Edition.

IPT="/sbin/iptables"
ETH="virbr0"
LOOPBACK_INTERFACE="lo"
LOOPBACK_IP="127.0.0.1"


#Remove  any  existing  rules  from  all  chains
$IPT --flush
$IPT -t nat --flush
$IPT -t mangle --flush

#Delete any user-defined chains
$IPT -X
$IPT -t nat -X
$IPT -t mangle -X

#  Reset  the  default  policy
$IPT --policy INPUT ACCEPT
$IPT --policy OUTPUT ACCEPT
$IPT --policy FORWARD ACCEPT
$IPT -t nat --policy PREROUTING ACCEPT
$IPT -t nat --policy OUTPUT ACCEPT
$IPT -t nat --policy POSTROUTING ACCEPT
$IPT -t mangle --policy PREROUTING ACCEPT
$IPT -t mangle --policy OUTPUT ACCEPT

# Parameter to allow script to stop the firewall
if ["$1" = "stop"]
 then
    echo "Firewall completely stopped! WARNING: THIS HOST HAS NO FIREWALL RUNNING."
    exit 0
fi

# Allow unlimited traffic on loopback interface
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT


#set the default policy to drop
$IPT --policy INPUT DROP
$IPT --policy OUTPUT DROP
$IPT --policy FORWARD DROP

#No forward policy necessary on personal firewall.
$IPT -t nat --policy PREROUTING DROP
$IPT -t nat --policy OUTPUT DROP
$IPT -t nat --policy POSTROUTING DROP
$IPT -t mangle --policy PREROUTING DROP
$IPT -t mangle --policy OUTPUT DROP



