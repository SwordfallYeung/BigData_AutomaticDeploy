#! /bin/bash

function configureSlaves()
{
 slavesUrl=$1
 
 cp $slavesUrl.template $slavesUrl

 sed -i 's/^[^#]/#&/' $slavesUrl
 echo "" >> $slavesUrl
 echo "node1" >> $slavesUrl
 echo "node2" >> $slavesUrl
 echo "node3" >> $slavesUrl
}

function configureSparkEnv()
{
 sparkEnvUrl=$1
  
 cp $sparkEnvUrl.template $sparkEnvUrl
 
 java_home=`egrep "^export JAVA_HOME=" /etc/profile`
 echo "$java_home" >> $sparkEnvUrl
 echo "\$SPARK_MASTER_IP=node1" >> $sparkEnvUrl
 echo "\$SPARK_MASTER_PORT=7077" >> $sparkEnvUrl
 echo "\$SPARK_WORKER_CORES=1" >> $sparkEnvUrl
 echo "\$SPARK_WORKER_INSTANCES=1" >> $sparkEnvUrl
 echo "\$SPARK_WORKER_MEMORY=900M" >> $sparkEnvUrl
}

function installSpark()
{
 #1.在frames.txt中查看是否需要安装spark
 sparkInfo=`egrep "^spark" /home/hadoop/automaticDeploy/frames.txt`

 spark=`echo $sparkInfo | cut -d " " -f1`
 isInstall=`echo $sparkInfo | cut -d " " -f2`

 echo $spark
 echo $isInstall
 
 #是否安装
 if [[ $isInstall = "true" ]];then
     
    #2.查看/opt/frames目录下是否有spark安装包
    sparkIsExists=`find /opt/frames -name $spark`
    echo $sparkIsExists
    if [[ ${#sparkIsExists} -ne 0 ]];then
        
        if [[ ! -d /opt/app ]];then
              mkdir /opt/app && chmod -R 775 /opt/app
        fi
       
        #删除旧的
        spark_home_old=`find /opt/app -maxdepth 1 -name "spark*"`
        for i in $spark_home_old;do
            rm -rf $i
        done

        #3.解压到指定文件夹/opt/app中
        echo "开始解压spark安装包"
        tar -zxvf $sparkIsExists -C /opt/app >& /dev/null
        echo "hadoop安装包解压完毕"

        spark_home=`find /opt/app -maxdepth 1 -name "spark*"`

        #4.配置slaves文件
        configureSlaves $spark_home/conf/slaves 
       
        #5.配置spark-env.sh文件
        configureSparkEnv $spark_home/conf/spark-env.sh
 
        #6.配置SPARK_HOME
        profile=/etc/profile
        sed -i "/^export SPARK_HOME/d" $profile
        echo "export SPARK_HOME=$spark_home" >> $profile

        #7.配置PATH
        sed -i "/^export PATH=\$PATH:\$SPARK_HOME\/bin/d" $profile
        echo "export PATH=\$PATH:\$SPARK_HOME/bin:\$SPARK_HOME/sbin" >> $profile

        #8.更新/etc/profile文件
        source /etc/profile && source /etc/profile
    else
        echo "/opt/frames目录下没有spark安装包"
    fi
 fi
}

installSpark
