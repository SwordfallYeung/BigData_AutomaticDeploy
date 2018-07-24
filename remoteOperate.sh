#! /bin/bash

<<<<<<< HEAD
function remoteChangeHostname()
{
 #1.判断pssh工具是否存在
 psshIsExists=`rpm -qa | grep pssh`
 if [ -z $psshIsExists ]
 then
     yum -y install pssh
 fi
}

remoteChangeHostname
=======
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
>>>>>>> 491703b5bf5f7b746f5ac30b490477887beaf1d7
