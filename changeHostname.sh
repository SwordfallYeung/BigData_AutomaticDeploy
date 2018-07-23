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

#获取参数
node=$1
echo $node
if [ -z $node ]
then
    echo "参数为空，请先输入参数"
else
    changeHostname $node
fi
