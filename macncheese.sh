#!/bin/bash

INTERFACE=wlp2s0
MONINTERFACE=wlp2s0mon

if [ "$EUID" -ne 0 ]
  then echo "Run as root"
  exit
fi

echo "Randomizing MAC address..."
ifconfig $INTERFACE down
#macchanger -b -r $INTERFACE > /dev/null
ifconfig wlp2s0 hw ether fc:25:3f:1e:69:81
ifconfig $INTERFACE up
echo "MAC address randomized."
echo ""

sleep 2

echo "Killing interfering processes..."
airmon-ng check kill > /dev/null
systemctl stop wpa_supplicant
systemctl stop NetworkManager
systemctl stop avahi-daemon > /dev/null
echo "Interfering processes killed."
echo ""

sleep 2

echo "Starting monitor mode..."
airmon-ng start $INTERFACE > /dev/null
echo "Monitor mode started."

echo "ESSID:"
read ESSID

airodump-ng $MONINTERFACE --berlin 60 -a --essid $ESSID

echo "Target MAC:"
read TARGETMAC

echo ""
echo "Stopping monitor mode..."
airmon-ng stop $MONINTERFACE > /dev/null
echo "Monitor mode stopped."

echo ""

sleep 2

echo "Setting MAC address..."
ifconfig $INTERFACE down
sleep 1
#macchanger -m $TARGETMAC $INTERFACE
ifconfig wlp2s0 hw ether $TARGETMAC
sleep 1
ifconfig $INTERFACE up
echo "MAC address set: "

echo "Restarting processes..."
systemctl start wpa_supplicant
echo "wpa_supplicant restarted."
systemctl start NetworkManager
echo "NetworkManager restarted."
systemctl start avahi-daemon
echo "avahi-daemon restarted."
echo "Processes restarted."
echo ""
