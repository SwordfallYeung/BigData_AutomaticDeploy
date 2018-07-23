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

#editHostFile 192.168.187.201,192.168.187.202,192.168.187.203

function sshFreeLogin()
{
 #1.获取三台机器ip地址
 ipString=$1
 
 #2.分割字符串 //与/之间是分割的字符，另外/后有一个空格不可省略
 ipSplit=${ipString//,/ }
 ipArr=($ipSplit)
 
 #3.遍历数组ipArr
 for((x=0;x<${#ipArr[*]};x++))
 do
    #ssh公私钥生成
    autoCreateSSH 
    
    #for((y=0;y<${#ipArr[*]};y++))
    #do
     #  echo ${ipArr[$x]}---${ipArr[$y]}
     #  n=`expr $y + 1`
      # ssh-copy-id node$n
    #done
 done
}

#sshFreeLogin 192.168.187.201,192.168.187.202,192.168.187.203

function autoCreateSSH()
{
 #1.检测expect服务是否存在，不存在则使用yum安装expect
 expectIsExists=`rpm -qa | grep expect` 
 if [ -z $expectIsExists ]
 then
      yum -y install expect
 fi
 
 #2.密钥对不存在则创建密钥
 [ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -t rsa -P "" -f /root/.ssh/id_rsa
 while read line;do
        #提取文件中的ip
        ip=`echo $line | cut -d " " -f1`
        #提取文件中的用户名
        user_name=`echo $line | cut -d " " -f2`
        #提取文件中的密码
        pass_word=`echo $line | cut -d " " -f3`
 expect <<EOF
          #复制公钥到目标主机
          spawn ssh-copy-id  $ip 
          expect {
                  #expect实现自动输入密码
                  "yes/no" { send "yes\n";exp_continue } 
                  "password" { send "$pass_word\n" }
          }
          expect eof
EOF
 done < /home/hadoop/automaticDeploy/host_ip.txt  # 读取存储ip的文件
}

autoCreateSSH
