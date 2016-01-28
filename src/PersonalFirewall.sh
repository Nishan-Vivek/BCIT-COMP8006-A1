#!/usr/bin/env bash

#Symbolic Constants as specified in Linux Firewalls 3rd Edition.

IPT="/sbin/iptables"
INTERNET="enp0s3"
LOOPBACK_INTERFACE="lo"
LOOPBACK_IP="127.0.0.1"
PRIVPORTS="0:1023"
UNPRIVPORTS="1024:65535"
BROADCAST_SRC="0.0.0.0"
BROADCAST_DEST="255.255.255.255"
IPADDR="192.168.1.30"
NAMESERVER="192.168.1.1"
DHCP_SERVER="192.168.1.1"
SSH_PORTS="1024:65535"

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
if [ "$1" = "stop" ]
 then
    echo "Firewall completely stopped! WARNING: THIS HOST HAS NO FIREWALL RUNNING."
    exit 0
fi

#set the default policy to drop
$IPT --policy INPUT DROP
$IPT --policy OUTPUT DROP
$IPT --policy FORWARD DROP


#User-defined chains
$IPT -N SSHin
$IPT -N SSHout
$IPT -N WWWin
$IPT -N WWWout


# Allow unlimited traffic on loopback interface
$IPT -A INPUT -i lo -j ACCEPT
$IPT -A OUTPUT -o lo -j ACCEPT

# Allow ICMP
iptables -A INPUT -p icmp -j ACCEPT
iptables -A OUTPUT -p icmp -j ACCEPT

#Allow DNS lookups
#$IPT -A OUTPUT -o $INTERNET -p udp -s $IPADDR --sport $UNPRIVPORTS -d $NAMESERVER --dport 53 -j ACCEPT
#$IPT -A INPUT -i $INTERNET -p udp -s $NAMESERVER --sport 53 -d $IPADDR --dport $UNPRIVPORTS -j ACCEPT
for ip in $NAMESERVER
do
	#echo "Allowing DNS lookups (tcp, udp port 53) to server '$ip'"
	$IPT -A OUTPUT -p udp -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
	$IPT -A INPUT  -p udp -s $ip --sport 53 -m state --state ESTABLISHED     -j ACCEPT
	$IPT -A OUTPUT -p tcp -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
	$IPT -A INPUT  -p tcp -s $ip --sport 53 -m state --state ESTABLISHED     -j ACCEPT
done

#DHCP
$IPT -A OUTPUT -o $INTERNET -p udp -s $BROADCAST_SRC --sport 68 -d $BROADCAST_DEST --dport 67 -j ACCEPT
$IPT -A INPUT -i $INTERNET -p udp -s $BROADCAST_SRC --sport 67 -d $BROADCAST_DEST --dport 68 -j ACCEPT
$IPT -A OUTPUT -o $INTERNET -p udp -s $BROADCAST_SRC --sport 68 -d $DHCP_SERVER --dport 67 -j ACCEPT
$IPT -A INPUT -i $INTERNET -p udp -s $DHCP_SERVER --sport 67 -d $BROADCAST_DEST --dport 68 -j ACCEPT
$IPT -A INPUT -i $INTERNET -p udp -s $DHCP_SERVER --sport 67 --dport 68 -j ACCEPT
$IPT -A OUTPUT -o $INTERNET -p udp -s $IPADDR --sport 68 -d $DHCP_SERVER --dport 67 -j ACCEPT
$IPT -A INPUT -i $INTERNET -p udp -s $DHCP_SERVER --sport 67 -d $IPADDR --dport 68 -j ACCEPT


#Drop all incoming packets from reserved port 0 as well as outbound traffic to port 0.
$IPT -A INPUT -i $INTERNET -p tcp --sport 0 -j DROP
$IPT -A INPUT -i $INTERNET -p udp --sport 0 -j DROP
$IPT -A OUTPUT -o $INTERNET -p tcp --dport 0 -j DROP
$IPT -A OUTPUT -o $INTERNET -p udp --dport 0 -j DROP


#Jump allowed WWW traffic to chain
$IPT -A OUTPUT -o $INTERNET -p tcp -s $IPADDR --sport $UNPRIVPORTS --dport 80 -j WWWout
$IPT -A INPUT -i $INTERNET -p tcp ! --syn --sport 80 -d $IPADDR --dport $UNPRIVPORTS -j WWWin
$IPT -A INPUT -i $INTERNET -p tcp --sport $UNPRIVPORTS -d $IPADDR --dport 80 -j WWWin
$IPT -A OUTPUT -o $INTERNET -p tcp ! --syn -s $IPADDR --sport 80 --dport $UNPRIVPORTS -j WWWout
$IPT -A OUTPUT -o $INTERNET -p tcp -s $IPADDR --sport $UNPRIVPORTS --dport 443 -j WWWout
$IPT -A INPUT -i $INTERNET -p tcp ! --syn --sport 443 -d $IPADDR --dport $UNPRIVPORTS -j WWWin
$IPT -A INPUT -i $INTERNET -p tcp --sport $UNPRIVPORTS -d $IPADDR --dport 443 -j WWWin
$IPT -A OUTPUT -o $INTERNET -p tcp ! --syn -s $IPADDR --sport 443 --dport $UNPRIVPORTS -j WWWout


#WWW chain accounting and accept
$IPT -A WWWout
$IPT -A WWWout -j ACCEPT
$IPT -A WWWin
$IPT -A WWWin -j ACCEPT


#Jump allowed SSH traffic to chain
$IPT -A OUTPUT -o $INTERNET -p tcp -s $IPADDR --sport $SSH_PORTS --dport 22 -j SSHout
$IPT -A INPUT -i $INTERNET -p tcp ! --syn --sport 22 -d $IPADDR --dport $SSH_PORTS -j SSHin
$IPT -A INPUT -i $INTERNET -p tcp --sport $SSH_PORTS -d $IPADDR --dport 22 -j SSHin
$IPT -A OUTPUT -o $INTERNET -p tcp ! --syn -s $IPADDR --sport 22 --dport $SSH_PORTS -j SSHout

#SSH chain accounting and accept
$IPT -A SSHout
$IPT -A SSHout -j ACCEPT
$IPT -A SSHin
$IPT -A SSHin -j ACCEPT


