#!/bin/bash



sudo su

#Enable IPv4 forwarding
sudo sed '/net.ipv4.ip_forward=1/s/^#//' -i /etc/sysctl.conf
sudo sysctl -p

#Create variable for host's public IP
first_ip_address="$(curl -Ls ifconfig.me)"

echo "Your public IP is: " $first_ip_address

cd /etc/wireguard/
#touch /etc/wireguard/wg0.conf

#Generate public/private keypair 
umask 077; wg genkey | tee privatekey | wg pubkey > publickey

#Create variable for private key
private_key=$(< privatekey)

load_config="
[Interface]
PrivateKey =a_private_key
Address = 10.0.0.0/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
[Peer]
AllowedIPS = 10.0.0.1/24
PersistentKeepalive = 25
"


#Populate begining of config file
sudo echo "$load_config" | tee -a /etc/wireguard/wg0.conf

sleep 2

#Sed script to replace string w/ variable
sed -i "s/a_private_key/$private_key/g" /etc/wireguard/wg0.conf