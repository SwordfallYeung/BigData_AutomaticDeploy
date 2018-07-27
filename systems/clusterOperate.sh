#! /bin/bash

function clusterOperate()
{
 #1.远程复制文件
  while read line;
  do
    hostname=`echo $line | cut -d " " -f2`
    echo "目前正在设置$hostname节点的系统环境"
    
    #默认node1为本地主机
    if [[ $hostname = "node1" ]]
    then
        #2.本地主机操作
        /home/hadoop/automaticDeploy/systems/batchOperate.sh $hostname
    else
        #3.远程主机操作
        if ssh -n $hostname test -e /home/hadoop/automaticDeploy
        then
             #3.1 存在则先删除旧的
             ssh -n $hostname "rm -rf /home/hadoop/automaticDeploy"
        fi
 
        #3.2 把本地的automaticDeploy里面的脚本文件复制到远程主机上
        scp -r /home/hadoop/automaticDeploy/ $hostname:/home/hadoop/automaticDeploy

        #3.3 把本地的/opt/frames里的软件安装包复制到远程主机的/opt/frames上
        #判断远程主机上/opt/frames是否存在，不存在则创建 
        if ssh -n $hostname test -e /opt/frames/;then
            echo "存在" > /dev/null
        else
            ssh -n $hostname "mkdir /opt/frames"
        fi
   
        #遍历需要安装的软件
        while read lineString;
        do
          software=`echo $lineString | cut -d " " -f1`
          isInstall=`echo $lineString | cut -d " " -f2`
          if [[ $isInstall = "true" ]];then
              if ssh -n $hostname test -e /opt/frames/$software;then
                  echo "存在" > /dev/null
              else  
                  scp /opt/frames/$software $hostname:/opt/frames/$software
              fi
          fi
        done < /home/hadoop/automaticDeploy/frames.txt
 
        #4.远程执行文件
        ssh -n $hostname /home/hadoop/automaticDeploy/systems/batchOperate.sh $hostname
    fi
  done < /home/hadoop/automaticDeploy/host_ip.txt

}

clusterOperate
