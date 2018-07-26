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
        /home/hadoop/automaticDeploy/batchOperate.sh $hostname
    else
        #3.远程主机操作
        if ssh -n $hostname test -e /home/hadoop/automaticDeploy
        then
             #3.1 存在则先删除旧的
             ssh -n $hostname "rm -rf /home/hadoop/automaticDeploy"
        fi
        #3.2 把本地的automaticDeploy里面的脚本文件复制到远程主机上
        scp -r /home/hadoop/automaticDeploy/ $hostname:/home/hadoop/automaticDeploy
        #4.远程执行文件
        ssh -n $hostname /home/hadoop/automaticDeploy/batchOperate.sh $hostname
    fi
  done < /home/hadoop/automaticDeploy/host_ip.txt

}

clusterOperate
