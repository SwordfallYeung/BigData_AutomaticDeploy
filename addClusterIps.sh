#! /bin/bash

#添加Ip、hostname到/etc/hosts文件里面
function addIpToHostFile()
{
 ip=$1
 hostname=$2
 #查询$ip1 node1是否存在于/etc/hosts里面
 egrep "^$ip $hostname" /etc/hosts >& /dev/null
 if [ $? -ne 0 ]
 then
     echo "$ip $hostname" >> /etc/hosts
 fi
}

#执行ssh免密登录之前，hosts文件里面需要存储每台机器的ip地址
function editHostFile()
{
 echo "edit the host file"
 
 #1./home/hadoop/host_ip.txt文件中读取ip和hostname
 while read line
 do
   #提取文件中的ip
   ip=`echo $line | cut -d " " -f1`
   #提取文件中的用户名
   hostname=`echo $line | cut -d " " -f2`
   echo $ip-$hostname
   addIpToHostFile $ip $hostname
 done < /home/hadoop/automaticDeploy/host_ip.txt #读取存储ip的文件

 echo "edit the host file successfully"
}

editHostFile
