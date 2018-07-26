#! /bin/bash

#修改机器名hostname
function changeHostname()
{
 hostname=$1
 #echo "change the hostname $1"
 
 egrep "^HOSTNAME=" /etc/sysconfig/network >& /dev/null
 if [ $? -eq 0 ]
 then
      #存在则删除旧的hostname
      sed -i "/^HOSTNAME=/d" /etc/sysconfig/network
 fi
 #添加新的hostname
 echo "HOSTNAME=$hostname" >> /etc/sysconfig/network
 
 #echo "change the hostname $1 successfully"
}

#获取参数
node=$1

if [ -z $node ]
then
    echo "参数为空，请输入参数node1,node2,node3..."
else
    changeHostname $node
fi
