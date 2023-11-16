#!/bin/bash
# Name: Philip Scheirich
# Course ID: COMP2137 - Linux Automation
# Assignment: Assignment 2
# Professor: D. Simpson
# Date: November 1, 2023
# Due: Nov  16


# Variable names here
#-----------------------------------------------------

#Assigns the username to the 'USERNAME' variable.
USERNAME=$(whoami)

# Defines the static IP address for a specific interface.
STATIC_IP="192.168.16.21/24"

#Retrieves the default route interface from the routing table.
DEFAULT_RIF=$(ip route show default | awk '/default/ {print $5}')

#Lists all network interfaces on the system.
ALLINTERFACES=($(ls /sys/class/net/))

#Stores the name of the interface that is the available route.
AVAIILABLE_IF=""

#Retrieves the static IP hostname /etc/hosts.
STATIC_HN=$(awk -v ip="$STATIC_IP" '$1 == ip {print $2}' /etc/hosts)


#Takes output from ufw commands and stores them for later use.
UFW_MESSAGE=""

##User configuration: List of usernames for accounts.
USERNAMES=("dennis" "aubrey" "captain" "snibbles" "brownie" "scooter" "sandy" "perrier" "cindy" "tiger" "yoda")


ls /etc/netplan | sort | wc -l

#Finds an available interface that isn't used as the default route.
for INTERFACE in "${ALLINTERFACES[@]}"; do
    if [[ "$INTERFACE" != "$DEFAULT_RIF" ]]; then
        AVAIILABLE_IF="$INTERFACE"
        break
    fi
done

echo "Internet Interface: $AVAIILABLE_IF"
#Displays the interface selected for the static configuration.
echo -e "
Configured Interface: $AVAIILABLE_IF"

sed -i "/$AVAIILABLE_IF/, /^\s*e/ {/$AVAIILABLE_IF/ s/^/#/; /^\s*e/! s/^/#/}" /etc/netplan/50-cloud-init.yaml
#Check if the entry associated with AVAIILABLE_IF is already commented out in netplan configuration.
for NETPLANFILE in /etc/netplan/*.yaml; do
    if ! grep -q "^#" "$NETPLANFILE"; then
#Comment out the set range.
        sed -i "/$AVAIILABLE_IF/, /^\s*e/ {/$AVAIILABLE_IF/ s/^/#/; /^\s*e/! s/^/#/}" "$NETPLANFILE"
    fi
done

#Next step is creating a Netplan configuration file for static IP
cat > /etc/netplan/01-static-int.yaml <<EOF
network:
    version: 2
@@ -115,20 +181,166 @@ network:
                search: [home.arpa, localdomain]
EOF

#while ! lxc exec "$container" -- systemctl is-active --quiet ssh 2>/dev/null; do sleep 1; done

#     lxc exec "$container" -- sh -c "cat > /etc/netplan/50-cloud-init.yaml <<EOF
# network:
#     version: 2
#     ethernets:
#         eth0:
#             addresses: [$containerlanip/24]
#             routes:
#               - to: default
#                 via: $lannetnum.2
#             nameservers:
#                 addresses: [$lannetnum.2]
#                 search: [home.arpa, localdomain]
#         eth1:
#             addresses: [$containermgmtip/24]
# EOF
#Displaying a message about the created Netplan file and showing the name and file location for the user to inspect.
echo -e "
Created Netplan file for static configuration: /etc/netplan/01-static-int.yaml"

#Check if an entry exists in /etc/hosts for the static interface's IP.
if grep -q "$STATIC_IP" /etc/hosts; then

#If the entry exists, it is updated with a new host name.

    sed -i "/^192.168.16.21\/24[[:space:]]/s/.*/&static-interface/" /etc/hosts


    ETCHOSTSENTRY=$(cat /etc/hosts | grep $STATIC_IP)

    echo -e "
Updated entry to /etc/hosts:$ETCHOSTSENTRY"
else

#If the entry doesn't exist, add it to the file with a host name.
    echo "$STATIC_IP static-interface" >> /etc/hosts

    ETCHOSTSENTRY=$(cat /etc/hosts | grep $STATIC_IP)

    echo -e "
Added entry to /etc/hosts:$ETCHOSTSENTRY"
fi
#Check if openssh-server service is running
if ! service ssh status &> /dev/null; then
    echo -e "
OpenSSH-server service not found; Installing."
    sudo apt install -y openssh-server
else
 #OpenSSH server service
    echo -e "
OpenSSH server service already installed; Continuing."
fi

#Configure OpenSSH for key-based authentication while ensuring the password authentication step is disabled.
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

#Check if Apache2 web server service is running
if ! service apache2 status &> /dev/null; then
    echo -e "
Apache2 web server service not found; Installing."
    sudo apt install -y apache2
else
 #Apache2 web server service is running
    echo -e "
Apache2 web server service already installed; Continuing."
fi

#Check if Squid web proxy service is running
if ! service squid status &> /dev/null; then
    echo -e "
Squid web proxy service not found; Installing."
    sudo apt install -y squid
else
 #Squid web proxy service is running
    echo -e "
Squid web proxy service already installed; Continuing. "
fi

#Configure Squid to listen on port 3128
sudo sed -i 's/http_port 3128/http_port 3128/' /etc/squid/squid.conf
sudo systemctl restart squid
#Enable UFW 
UFW_MESSAGE=$(sudo ufw --force enable)
echo -e "
Enabling UFW (Uncomplicated Firewall): $UFW_MESSAGE"

#Allow SSH on port 22
UFW_MESSAGE=$(sudo ufw allow 22)
echo -e "
Enabling UFW (Uncomplicated Firewall): $UFW_MESSAGE"

#Allow HTTP on port 80
UFW_MESSAGE=$(sudo ufw allow 80)
echo -e "
Enabling UFW (Uncomplicated Firewall): $UFW_MESSAGE"

#Allow HTTPS on port 443
UFW_MESSAGE=$(sudo ufw allow 443)
echo -e "
Enabling UFW (Uncomplicated Firewall): $UFW_MESSAGE"

#Allow web proxy on port 3128
UFW_MESSAGE=$(sudo ufw allow 3128)
echo -e "
Enabling UFW (Uncomplicated Firewall): $UFW_MESSAGE"
#Create users with home directory and bash as default shell
for USERNAME in "${USERNAMES[@]}"; do
    if id "$USERNAME" &>/dev/null; then
        echo -e "
${YELLOW}User already exists: $USERNAME"
    else
        sudo useradd -m -s /bin/bash "$USERNAME" > /dev/null 2>&1
        echo -e "Creating user: $USERNAME"
    fi
done

#SSH key configuration
for USERNAME in "${USERNAMES[@]}"; do
#Generate SSH keys
    echo -e "
Generating SSH key:"
    echo -e "y\n" | sudo -u "$USERNAME" ssh-keygen -t rsa -b 2048 -f "/home/$USERNAME/.ssh/id_rsa" -N "" > /dev/null
    echo -e "y\n" | sudo -u "$USERNAME" ssh-keygen -t ed25519 -f "/home/$USERNAME/.ssh/id_ed25519" -N "" > /dev/null

#Check if the SSH key file already exists and print a message
    if [ -f "/home/$USERNAME/.ssh/id_rsa" ] || [ -f "/home/$USERNAME/.ssh/id_ed25519" ]; then
        echo -e "${YELLOW}SSH keys already exist for: $USERNAME. ${RED}Overwriting..."
    fi

#Add the public key from the assignment, then give sudo access to "dennis"
    if [ "$USERNAME" == "dennis" ]; then
        sudo usermod -aG sudo dennis
        echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG4rT3vTt99Ox5kndS4HmgTrKBT8SKzhK4rhGkEVGlCI student@generic-vm" | sudo -u dennis tee -a "/home/dennis/.ssh/authorized_keys" > /dev/null
    fi

#Add the generated public keys to authorized keys
    cat "/home/$USERNAME/.ssh/id_rsa.pub" >> "/home/$USERNAME/.ssh/authorized_keys"
    cat "/home/$USERNAME/.ssh/id_ed25519.pub" >> "/home/$USERNAME/.ssh/authorized_keys"

#Set correct permissions for the .ssh directory and authorized keys file
    chmod 700 "/home/$USERNAME/.ssh"
    chmod 600 "/home/$USERNAME/.ssh/authorized_keys"
    
    echo "Thank you for viewing my script results."

    done
    