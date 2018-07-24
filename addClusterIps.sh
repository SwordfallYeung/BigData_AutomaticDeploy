#! /bin/bash

#添加Ip、hostname到/etc/hosts文件里面
function addIpToHostFile()
{
 ip=$1
 hostname=$2
 #查询$ip是否存在于/etc/hosts里面
 egrep "^$ip" /etc/hosts >& /dev/null
 if [ $? -eq 0 ]
 then
     #$?是上一个程序执行是否成功的标志，如果执行成功则$?为0，否则不为0，存在则先把就的ip设置删除掉
     sed -i "/^$ip/d" /etc/hosts
 fi
 
 #把ip、hostname添加到/etc/hosts中
 echo "$ip $hostname" >> /etc/hosts
}

#执行ssh免密登录之前，hosts文件里面需要存储每台机器的ip地址
function editHostFile()
{
 #echo "edit the host file"
 
 #1./home/hadoop/host_ip.txt文件中读取ip和hostname
 while read line
 do
   #提取文件中的ip
   ip=`echo $line | cut -d " " -f1`
   #提取文件中的用户名
   hostname=`echo $line | cut -d " " -f2`

   addIpToHostFile $ip $hostname
 done < /home/hadoop/automaticDeploy/host_ip.txt #读取存储ip的文件

 #echo "edit the host file successfully"
}

editHostFile
