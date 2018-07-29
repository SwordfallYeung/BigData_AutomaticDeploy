#! /bin/bash

function installKafka()
{
  #1.在frames.txt中查看是否需要安装kafka
 kafkaInfo=`egrep "^kafka" /home/hadoop/automaticDeploy/frames.txt`

 kafka=`echo $kafkaInfo | cut -d " " -f1`
 isInstall=`echo $kafkaInfo | cut -d " " -f2`
 
 #是否安装
 if [[ $isInstall = "true" ]];then
     
     #2.查看/opt/frames目录下是否有kafka安装包
     kafkaIsExists=`find /opt/frames -name $kafka`
    
     if [[ ${#kafkaIsExists} -ne 0 ]];then
           
          if [[ ! -d /opt/app ]];then
              mkdir /opt/app && chmod -R 775 /opt/app
          fi
   
          #删除旧的
          kafka_home_old=`find /opt/app -maxdepth 1 -name "kafka*"`
          for i in $kafka_home_old;do
                rm -rf $i
          done

          #3.解压到指定文件夹/opt/app中
          echo "开始解压kafka安装包"
          tar -zxvf $kafkaIsExists -C /opt/app >& /dev/null
          echo "kafka安装包解压完毕"
          
          kafka_home=`find /opt/app -maxdepth 1 -name "kafka*"`

          #4.搭建zookeeper集群
          
          #5.修改配置文件server.properties
          serverUrl=$kafka_home/config/server.properties
          broker_id=0
          num=`sed -n -e "/#listeners=PLAINTEXT:\/\/:9092/=" $serverUrl`
          sed -i "${num}a listeners=PLAINTEXT:\/\/node1:9092" $serverUrl
	  
          num_log=`sed -n -e "/log.dirs=\/tmp\/kafka-logs/=" $serverUrl`
          sed -i 's/log.dirs=\/tmp\/kafka-logs/#&/' $serverUrl
	  sed -i "${num_log}a log.dirs=${kafka_home}/logs" $serverUrl
          mkdir $kafka_home/logs
          
          num_zk=`sed -n -e "/zookeeper.connect=localhost:2181/=" $serverUrl`
          sed -i 's/zookeeper.connect=localhost:2181/#&/' $serverUrl
          sed -i "${num_zk}a zookeeper.connect=node1:2181,node2:2181,node3:2181" $serverUrl
         
          #6.配置KAFKA_HOME
          profile=/etc/profile
          sed -i "/^export KAFAK_HOME/d" $profile
          echo "export KAFAK_HOME=$kafka_home" >> $profile

          #7.配置PATH
          sed -i "/^export PATH=\$PATH:\$KAFKA_HOME\/bin/d" $profile
          echo "export PATH=\$PATH:\$KAFKA_HOME/bin" >> $profile

          #8.更新/etc/profile文件
          source /etc/profile && source /etc/profile
     else
         echo "/opt/frames目录下没有kafka安装包"
     fi
 else
     echo "/opt/frames目录下没有kafka安装包"
 fi
}

installKafka
