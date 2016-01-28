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


# Test for stealth scans and TCP state flags
#  Unclean
$IPT -A INPUT -m unclean -j DROP
#  All  of  the  bits  are  cleared
$IPT -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
#  SYN  and  FIN  are  both  set
$IPT -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
#  SYN  and  RST  are  both  set
$IPT -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
#  FIN  and  RST  are  both  set
$IPT -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
#  FIN  is  the  only  bit  set,  without  the  expected  accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP
#  PSH  is  the  only  bit  set,  without  the  expected  accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP
#  URG  is  the  only  bit  set,  without  the  expected  accompanying ACK
$IPT -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP





#Permit inbound/outbound ssh packets

#Permit inbound/outbound www packets

#Drop inbound traffic to port 80 (http) from source ports less than 1024

#Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0.

#Create a set of user-defined chains that will implement accounting rules to keep track of www, ssh traffic, versus the rest of the traffic on your system.

#You must ensure the the firewall drops all inbound SYN packets, unless there is a rule that permits inbound traffic.

#Remember to allow DNS and DHCP traffic through so that your machine can function properly

