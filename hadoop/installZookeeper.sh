#! /bin/bash

function installZK()
{
  #1.在frames.txt中查看是否需要安装zk
  zkInfo=`egrep "^zookeeper" /home/hadoop/automaticDeploy/frames.txt`
 
  zk=`echo $zkInfo | cut -d " " -f1`
  isInstall=`echo $zkInfo | cut -d " " -f2`

  #是否安装
  if [[ $isInstall = "true" ]];then
      
     #2.查看/opt/frames目录下是否有zk安装包
     zkIsExists=`find /opt/frames -name $zk`
     if [[ ${#zkIsExists} -ne 0 ]];then
         
        if [[ ! -d /opt/app ]];then
           mkdir /opt/app && chmod -R 775 /opt/app
        fi
  
        #删除旧的
        zk_home_old=`find /opt/app -maxdepth 1 -name "zookeeper*"`
        for i in $zk_home_old;do
             rm -rf $i
        done

        #3.解压到指定文件夹/opt/app中
        echo "开始解压zookeeper安装包"
        tar -zxvf $zkIsExists -C /opt/app >& /dev/null
        echo "zookeeper安装包解压完毕"
 
        zk_home=`find /opt/app -maxdepth 1 -name "zookeeper*"`

        #4.编辑zoo.cfg文件
        zooUrl=$zk_home/conf/zoo.cfg
        cp $zk_home/conf/zoo_sample.cfg $zooUrl
        num_data=`sed -n -e "/^dataDir=\/tmp\/zookeeper/=" $zooUrl`
        sed -i 's/^dataDir=\/tmp\/zookeeper/#&/' $zooUrl
        sed -i "${num_data}a dataDir=${zk_home}/data" $zooUrl
        echo "" >> $zooUrl
        echo "server.1=node1:2888:3888" >> $zooUrl
        echo "server.2=node2:2888:3888" >> $zooUrl
        echo "server.3=node3:2888:3888" >> $zooUrl

        #4.编辑日志输出类型和输出目录
        log4jUrl=$zk_home/conf/log4j.properties
        sed -i 's/^log4j.rootLogger=\${zookeeper.root.logger}/#&/' $log4jUrl
        num_log=`sed -n -e "/^#log4j.rootLogger=DEBUG, CONSOLE, ROLLINGFILE/=" $log4jUrl`
        sed -i "${num_log}a log4j.rootLogger=INFO, ROLLINGFILE" $log4jUrl
 
        sed -i 's/ZOO_LOG_DIR="."/ZOO_LOG_DIR="${zk_home}\/logs"/' $zk_home/bin/zkEnv.sh

        #4.在zookeeper安装目录下创建data、logs文件夹
        mkdir -m 755 $zk_home/data
        mkdir -m 755 $zk_home/logs

        #5.在data文件夹下新建myid文件，myid的文件内容为
        echo "1" > $zk_home/data/myid

        #6.配置ZOOKEEPER_HOME
        profile=/etc/profile
        sed -i "/^export ZOOKEEPER_HOME/d" $profile
        echo "export ZOOKEEPER_HOME=$zk_home" >> $profile

        #7.配置PATH
        sed -i "/^export PATH=\$PATH:\$ZOOKEEPER_HOME\/bin/d" $profile
        echo "export PATH=\$PATH:\$ZOOKEEPER_HOME/bin" >> $profile
 
        #8.更新/etc/profile文件
        source /etc/profile && source /etc/profile
     else
         echo "/opt/frames目录下没有zookeeper安装包"
     fi
  else 
      echo "/opt/frames目录下没有zookeeper安装包"
  fi
}

installZK
