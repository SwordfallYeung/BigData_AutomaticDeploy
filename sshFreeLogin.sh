#! /bin/bash

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
        hostname=`echo $line | cut -d " " -f2`
        #提取文件中的用户名
        user_name=`echo $line | cut -d " " -f3`
        #提取文件中的密码
        pass_word=`echo $line | cut -d " " -f4`
 expect <<EOF
          #复制公钥到目标主机
          spawn ssh-copy-id  $hostname
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
