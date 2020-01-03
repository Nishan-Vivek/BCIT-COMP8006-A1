BCIT COMP8006 Assignment 1 - Personal Linux Firewall

# Objective 

To implement and test a simple personal Linux firewall.

## Requirements

  - Permit inbound/outbound ssh packets (port 22).

  - Permit inbound/outbound www packets (ports 80, 443).

  - Drop inbound traffic to port 80 (http) from source ports less than
    1024.

  - Drop all incoming packets from reserved port 0 as well as outbound
    traffic to port 0.

  - Create a set of user-defined chains that will implement accounting
    rules to keep track of www, ssh traffic, versus the rest of the
    traffic on your system.

  - allow DNS and DHCP traffic through so that your machine can function
    properly.

# Initial Design

The assignment is composed of a bash script that will setup a netfilter
firewall as per the assignment requirements utilizing the iptables
management app. Setup will follow the guidelines provided in the text
“Linux Firewalls 3<sup>rd</sup> edition” from chapter 4.

## 

## Design Diagrams

### Input Chain

![](.//media/image1.PNG)

### Output Chain

![](.//media/image2.png)

# Implementation 

The project was scripted in a Bash Script using iptables for a Fedora 22
environment. The script has several user defined variables which need to
be adjusted as per the network setup. These are at the top of the
script. Six user defined chains were created so that SSH and WWW traffic
could be accounted for against all other accepted traffic.

## Execution Instructions

Extract the submitted zip file on the respective host machine and
navigate to the “Firewall” folder. As root run the firewall.sh script
with the following command line:

“./firewall.sh”

If you wish to reset the firewall to accept all run the script with the
“stop” parameter:

“./firewall.sh stop”

# Tests

### Test 1 – Verify rules are added

Method: iptables -L -v -n -x

Result: Valid

![](.//media/image3.tmp)

## Test 2 – Verify DNS Lookup with host

Method: host -t a bcit.ca

Result: Valid

![](.//media/image4.png)

## Test 3 – Verify DHCP with dhcping

Method: dhcping -s “DHCP Server IP”

Result: Valid

![](.//media/image5.png)

## Test 4 – Verify incoming SSH packet with hping3

Method: hping3 “Firewall IP” -S -p 22 -c 3

Result: Valid

![](.//media/image6.png)

## Test 5 – Verify WWW with browser

Method: Visit [www.bcit.ca](http://www.bcit.ca) to check HTTP and
[www.google.ca](http://www.google.ca) to check HTTPS.

Result: Valid – Screen shots omitted to save space.

## Test 6 – Verify incoming WWW packet with hping3 port 80

Method: hping3 “Firewall IP” -S -p 80 -c 3

Result: Valid

![](.//media/image7.png)

## Test 7 – Verify incoming WWW packet with hping3 port 443

Method: hping3 “Firewall IP” -S -p 443 -c 3

Result: Valid

![](.//media/image8.png)

## Test 8 – Verify incoming SSH request with SSH

Method: ssh “firewall ip”

Result: Valid

![](.//media/image9.png)

## Test 9 – Verify outgoing SSH request with SSH

Method: ssh “outside ip”

Result: Valid

![](.//media/image10.png)
