#! /bin/bash

#执行ssh免密登录之前，hosts文件里面需要存储每台机器的ip地址
function editHostFile()
{
 echo "edit the host file"
 
 #获取三台机器ip地址
 ip1=$1
 ip2=$2
 ip3=$3
 
 addIpToHostFile $ip1 node1
 addIpToHostFile $ip2 node2
 addIpToHostFile $ip3 node3

 echo "edit the host file successfully"
}

function addIpToHostFile()
{
 ip=$1
 #查询$ip1 node1是否存在于/etc/hosts里面
 egrep "^$ip $node" /etc/hosts >& /dev/null
 if [ $? -ne 0 ]
 then
     echo "$ip $node" >> /etc/hosts
 fi
}

#editHostFile 192.168.187.201 192.168.187.202 192.168.187.203


