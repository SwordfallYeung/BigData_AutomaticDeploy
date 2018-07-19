#! /bin/bash

#执行ssh免密登录之前，hosts文件里面需要存储每台机器的ip地址
function editHostFile()
{
 echo "edit the host file"
 
 #获取三台机器ip地址
 ipString=$1
 #1.分割字符串 //与/之间是分割的字符，另外/后有一个空格不可省略
 ipSplit=${ipString//,/ }
 ipArr=($ipSplit)
  
 #2.遍历数组ipArr
 for((x=0;x<${#ipArr[*]};x++))
 do
    #echo ${ipArr[$x]}
    y=`expr $x + 1`
    addIpToHostFile ${ipArr[$x]} node$y
 done 

 echo "edit the host file successfully"
}

function addIpToHostFile()
{
 ip=$1
 node=$2
 #查询$ip1 node1是否存在于/etc/hosts里面
 egrep "^$ip $node" /etc/hosts >& /dev/null
 if [ $? -ne 0 ]
 then
     echo "$ip $node" >> /etc/hosts
 fi
}

editHostFile 192.168.187.201,192.168.187.202,192.168.187.203


