#! /bin/bash

#修改机器名hostname
function changeHostname()
{
 echo "change the hostname"
 hostname=$1
 egrep "^HOSTNAME=" /etc/sysconfig/network >& /dev/null
 if [ $? -eq 0 ]
 then
      sed -i "/^HOSTNAME=/d" /etc/sysconfig/network
 fi
 echo "HOSTNAME=$hostname" >> /etc/sysconfig/network
 echo "change the hostname successfully"
}

changeHostname node1
