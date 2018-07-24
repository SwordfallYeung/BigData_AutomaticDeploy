#! /bin/bash

function remoteOperate()
{
 #1.远程复制文件
  while read line;
  do
    hostname=`echo $line | cut -d " " -f2`
    if [[ $hostname = "node2" ]]
    then
        scp -r /home/hadoop/automaticDeploy/ $hostname:/home/hadoop/automaticDeploy
        ssh $hostname > /dev/null 2>&1  << REMOTE
        /home/hadoop/automaticDeploy/changeHostname.sh $hostname
        /home/hadoop/automaticDeploy/addClusterIps.sh
REMOTE
    fi
  done < /home/hadoop/automaticDeploy/host_ip.txt
 #scp -r /home/hadoop/automaticDeploy/ node3:/home/hadoop/automaticDeploy
}

remoteOperate
