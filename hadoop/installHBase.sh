#! /bin/bash

function configureHbaseEnv()
{
 hbaseEnvUrl=$1
 
 java_home=`egrep "^export JAVA_HOME=" /etc/profile`
 num_java=`sed -n -e "/# export JAVA_HOME=/=" $hbaseEnvUrl`
 sed -i "${num_java}a $java_home" $hbaseEnvUrl

 hadoop_home=`find /opt/app -maxdepth 1 -name "hadoop*"`
 num_hadoop=`sed -n -e "/# export HBASE_CLASSPATH=/=" $hbaseEnvUrl`
 sed -i "${num_hadoop}a export HBASE_CLASSPATH=${hadoop_home}/etc/hadoop" $hbaseEnvUrl

 num_zk=`sed -n -e "/# export HBASE_MANAGES_ZK=true/=" $hbaseEnvUrl`
 sed -i "${num_zk}a export HBASE_MANAGES_ZK=true" $hbaseEnvUrl
}

function configureHbaseSite()
{
 hbaseSiteUrl=$1

 n=`sed -n -e "/<configuration>/="  $hbaseSiteUrl`
 sed -i "/^<\/configuration>/d" $hbaseSiteUrl
 
cat >> $hbaseSiteUrl << EOF
  #hbasemaster的主机和端口
  <property>
    <name>hbase.master</name> 
    <value>node1:60000</value>
  </property>

  #时间同步允许的时间差
  <property>
    <name>hbase.master.maxclockskew</name>
    <value>180000</value>
  </property>

  #hbase共享目录，持久化hbase数据
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://node1:9000/hbase</value>
  </property>

  #是否分布式运行，false即为单机
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>

  #zookeeper地址
  <property>
    <name>hbase.zookeeper.quorum</name>
    <value>node1,node2,node3</value>
  </property>

  #zookeeper配置信息快照的位置
  <property>
    <name>hbase.zookeeper.property.dataDir</name>
    <value>/home/hbase/tmp/zookeeper</value>
  </property>
</configuration>
EOF
}

function configureRegionservers()
{
 regionserversUrl=$1
 
 sed -i 's/^[^#]/#&/' $regionserversUrl
 
 cat >> $regionserversUrl << EOF
node1
node2
node3
EOF
}

function installHBase()
{
 #1.在frames.txt中查看是否需要安装hbase
 hbaseInfo=`egrep "^hbase" /home/hadoop/automaticDeploy/frames.txt`

 hbase=`echo $hbaseInfo | cut -d " " -f1`
 isInstall=`echo $hbaseInfo | cut -d " " -f2`
  
 #是否安装
 if [[ $isInstall = "true" ]];then
    
     #2.查看/opt/frames目录下是否有kafka安装包
     hbaseIsExists=`find /opt/frames -name $hbase`

     if [[ ${#hbaseIsExists} -ne 0 ]];then

          if [[ ! -d /opt/app ]];then
              mkdir /opt/app && chmod -R 775 /opt/app
          fi

          #删除旧的
          hbase_home_old=`find /opt/app -maxdepth 1 -name "hbase*"`
          for i in $hbase_home_old;do
                rm -rf $i
          done

          #3.解压到指定文件夹/opt/app中
          echo "开始解压hbase安装包"
          tar -zxvf $hbaseIsExists -C /opt/app >& /dev/null
          echo "hbase安装包解压完毕"

          hbase_home=`find /opt/app -maxdepth 1 -name "hbase*"`

          #4.配置hbase-env.sh文件
          configureHbaseEnv $hbase_home/conf/hbase-env.sh

          #5.配置hbase-site.xml文件
          configureHbaseSite $hbase_home/conf/hbase-site.xml

          #6.配置Regionservers文件
          configureRegionservers $hbase_home/conf/regionservers

          #7.把hadoop的hdfs-site.xml和core-site.xml放到hbase/conf下
          hadoop_home=`find /opt/app -maxdepth 1 -name "hadoop*"`
          cp $hadoop_home/etc/hadoop/hdfs-site.xml $hbase_home/conf/
          cp $hadoop_home/etc/hadoop/core-site.xml $hbase_home/conf/

          #8.配置HBASE_HOME
          profile=/etc/profile
          sed -i "/^export HBASE_HOME/d" $profile
          echo "export HBASE_HOME=$hbase_home" >> $profile

          #9.配置PATH
          sed -i "/^export PATH=\$PATH:\$HBASE_HOME\/bin/d" $profile
          echo "export PATH=\$PATH:\$HBASE_HOME/bin" >> $profile

          #10.更新/etc/profile文件
          source /etc/profile && source /etc/profile
     else
         echo "/opt/frames目录下没有hbase安装包1"
     fi
 else
     echo "/opt/frames目录下没有hbase安装包2"
 fi

}

installHBase
