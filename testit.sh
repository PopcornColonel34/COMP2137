#!/bin/bash
# Name: Ty Bradley
# Course: COMP2137 - Linux Automation
# Professor: Dennis Simpson
# Date: October 4th, 2023

# The purpose of this script is to display some important identity information about a computer so that you can see that information quickly and concisely, without having to memorize mutliple commands or remember multiple command options.

# Enstantiating variable names for script

# Variable for current user name.
USERNAME=$(whoami)
# Variable for current date.
CURRENTDATE=$(echo "null")
# Variable for current host.
HOSTNAME=$(echo "null")
# Variable for current Linux Distrobution with version.
DISTROWITHVERSION=$(echo "null")
# Current uptime.
UPTIME=$(echo "null")
# Current CPU information.
CPUINFO=$(echo "null")
# Current and Max Speed of CPU
CURRENTANDMAXSPEEDCPU=$(echo "null")

SIZERAM=$(echo "null")

MAKEMODELVGU=$(echo "null")

echo "
System Report generated by USERNAME, DATE/TIME
System Report generated by $USERNAME, $CURRENTDATE
------------------ 
System Information
------------------
Hostname: HOSTNAME
OS: DISTROWITHVERSION
Uptime: UPTIME
`# Current Hostname within system.`
Hostname: $HOSTNAME
`# Current Linux OS distribution within system.`
OS: $DISTROWITHVERSION
`# Current uptime of system.`
Uptime: $UPTIME
-------------------- 
Hardware Information
--------------------
cpu: PROCESSOR MAKE AND MODEL
Speed: CURRENT AND MAXIMUM CPU SPEED
Ram: SIZE OF INSTALLED RAM
`#cpu: PROCESSOR MAKE AND MODEL`
cpu: $CPUINFO
`#Speed: CURRENT AND MAXIMUM CPU SPEED`
Speed: $CURRENTANDMAXSPEEDCPU
`#Ram: SIZE OF INSTALLED RAM`
Ram: $SIZERAM
`#disk(s): MAKE AND MODEL AND SIZE FOR ALL INSTALLED DISKS`
Disk(s): MAKE AND MODEL AND SIZE FOR ALL INSTALLED DISKS
Video: MAKE AND MODEL OF VIDEO CARD
`#Video: MAKE AND MODEL OF VIDEO CARD`
Video: $MAKEMODELVGU
------------------- 
Network Information
-------------------
FQDN: FQDN
Host Address: IP ADDRESS FOR THE HOSTNAME
Gateway IP: GATEWAY ADDRESS
DNS Server: IP OF DNS SERVER
 
InterfaceName: MAKE AND MODEL OF NETWORK CARD
IP Address: IP Address in CIDR format
------------- 
System Status
-------------
Users Logged In: USER,USER,USER...
Disk Space: FREE SPACE FOR LOCAL FILESYSTEMS IN FORMAT: /
MOUNTPOINT N
Process Count: N
Load Averages: N, N, N
Memory Allocation: DATA FROM FREE
Listening Network Ports: N, N, N, ...
UFW Rules: DATA FROM UFW SHOW
"