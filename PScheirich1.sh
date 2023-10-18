#!/bin/bash
# Name: Philip Scheirich
# Course: COMP2137 - Linux Automation
# Professor: D. Simpson
# Date: October 18th, 2023

# Source to get OS information
source /etc/os-release
# Set the variable for the user
myname=`whoami`
# Get the current time and date
TIME=$(date +"%T")
#Get the hostname
HOSTNAME= $(hostname)
#Extract OS info from variables in /etc/os-releases
DISTRO="$NAME $VERSION"
#Show system uptime
UPTIME=$(uptime -p)
#Find specific CPU information
CPU_Details=$(lscpu | grep "Model name")
#Find current CPU speed
CPU_Speed=$(lscpu -e=+MHZ)
#Find current amount of free RAM
RAM_Size=$(free -h | awk '/^Mem:/ {print $2}')
#Display Disk information
DISK_info=$(lsblk -d -o NAME,MODEL,SIZE | grep -v "NAME")
#Video card information
VIDEO_card=$(lspci | grep -i "VGA")
# Display FQDN information
FQDN_info=$(hostname --fqdn)
# Show Host IP address
IP_address=$(hostname --ip-address)
#Show Default Gateway Information
GATEWAY_ip=$(ip route | awk '/default/ {print $3}')
#DNS Server details
DNS_servers=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
#Display Interface information
INTERFACE_names=$(ip link | awk -F ": " '{print $2}' | awk '{print $1}')

echo "
System Report generated by $myname on $TIME

SYSTEM INFORMATION
==================
Hostname: $HOSTNAME
OS: $DISTRO
Uptime: $UPTIME

HARDWARE INFORMATION
====================
CPU: 
$CPU_Details
Speed: 
$CPU_Speed
RAM: 
$RAM_Size
Disks:
$DISK_info
Video:
$VIDEO_card

NETWORK INFORMATION
===================

FQDN:
$FQDN_info
Host Address:
$IP_address
Gateway IP:
$GATEWAY_ip
DNS Server:
$DNS_servers
InterfaceName:
$INTERFACE_names
IP Address: IP Address in CIDR format

SYSTEM STATUS
=============

Users Logged In:
Disk Space:
Process Count:
Load Averages:
Memory Allocation:
Listening Network Ports:
UFW Rules:

"
