#!/bin/bash

function get_ip() 
{
    local intf=$1
    ifconfig $intf | grep 'inet addr:' | cut -f 2 -d: | cut -d' ' -f 1
    return $?
}

monitor=$1
if [ -z "$monitor" ]; then
  interfaces=`ls /sys/class/net | grep -v lo`
  echo "Auto detected interfaces [ $interfaces ]"
  monitor=`echo $interfaces | cut -d ' ' -f 1`
fi

echo
echo "Monitoring interface: $monitor"
echo 

IP=
while true; do
   curIP=`get_ip $monitor`
   
   if [ "$curIP" != "$IP" ]; then
     echo "# New IP [ $curIP ], old: [ $IP ]"
     IP="$curIP"
     echo "$IP" > /tmp/.mbsa.host.ip.tmp
	 mv /tmp/.mbsa.host.ip.tmp /tmp/.mbsa.host.ip
   fi

   sleep 1
done
