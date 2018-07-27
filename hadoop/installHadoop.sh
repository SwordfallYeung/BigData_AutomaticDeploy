#! /bin/bash
#
#基于CentOS7
#

function configureCoreSite()
{
 coreSiteUrl=$1
 
 sed -i "/^<\/configuration>/d" $coreSiteUrl
 
 #配置fs默认名字
 echo "  <property>" >> $coreSiteUrl
 echo "      <name>fs.default.name</name>" >> $coreSiteUrl
 echo "      <value>hdfs://node1:9000</value>" >> $coreSiteUrl
 echo "  </property>" >> $coreSiteUrl

 #配置默认FS
 echo "  <property>" >> $coreSiteUrl
 echo "      <name>fs.defaultFS</name>" >> $coreSiteUrl
 echo "      <value>hdfs://node1:9000</value>" >> $coreSiteUrl
 echo "  </property>" >> $coreSiteUrl

 #配置IO操作的文件缓冲区大小
 echo "  <property>" >> $coreSiteUrl
 echo "      <name>io.file.buffer.size</name>" >> $coreSiteUrl
 echo "      <value>131072</value>" >> $coreSiteUrl
 echo "  </property>" >> $coreSiteUrl

 #tmp目录
 echo "  <property>" >> $coreSiteUrl
 echo "      <name>hadoop.tmp.dir</name>" >> $coreSiteUrl
 echo "      <value>file:/opt/app/hadoop-2.7.6/tmp</value>" >> $coreSiteUrl
 echo "  </property>" >> $coreSiteUrl

 #代理用户hosts
 echo "  <property>" >> $coreSiteUrl
 echo "      <name>hadoop.proxyuser.hduser.hosts</name>" >> $coreSiteUrl
 echo "      <value>*</value>" >> $coreSiteUrl
 echo "  </property>" >> $coreSiteUrl

 #代理用户组
 echo "  <property>" >> $coreSiteUrl
 echo "      <name>hadoop.proxyuser.hduser.groups</name>" >> $coreSiteUrl
 echo "      <value>*</value>" >> $coreSiteUrl
 echo "  </property>" >> $coreSiteUrl

 echo "</configuration>" >> $coreSiteUrl

}

function configureHdfsSite()
{
 hdfsSiteUrl=$1
 
 n=`sed -n -e "/<configuration>/="  $hdfsSiteUrl`
 sed -i "`expr $n + 1`d" $hdfsSiteUrl
 sed -i "/^<\/configuration>/d" $hdfsSiteUrl
 
 #namenode的secondary配置
 echo "  <property>" >> $hdfsSiteUrl
 echo "      <name>dfs.namenode.secondary.http-address</name>" >> $hdfsSiteUrl
 echo "      <value>node1:9001</value>" >> $hdfsSiteUrl
 echo "  </property>" >> $hdfsSiteUrl

 #namenode的name配置
 echo "  <property>" >> $hdfsSiteUrl
 echo "      <name>dfs.namenode.name.dir</name>" >> $hdfsSiteUrl
 echo "      <value>file:/opt/app/hadoop-2.7.6/name</value>" >> $hdfsSiteUrl
 echo "  </property>" >> $hdfsSiteUrl

 #datanode的data配置
 echo "  <property>" >> $hdfsSiteUrl
 echo "      <name>dfs.datanode.data.dir</name>" >> $hdfsSiteUrl
 echo "      <value>file:/opt/app/hadoop-2.7.6/data</value>" >> $hdfsSiteUrl
 echo "  </property>" >> $hdfsSiteUrl

 #备份数目设置置
 echo "  <property>" >> $hdfsSiteUrl
 echo "      <name>dfs.replication</name>" >> $hdfsSiteUrl
 echo "      <value>2</value>" >> $hdfsSiteUrl
 echo "  </property>" >> $hdfsSiteUrl
 
 #开启webhdfs
 echo "  <property>" >> $hdfsSiteUrl
 echo "      <name>dfs.webhdfs.enabled</name>" >> $hdfsSiteUrl
 echo "      <value>true</value>" >> $hdfsSiteUrl
 echo "  </property>" >> $hdfsSiteUrl
  
 echo "</configuration>" >> $hdfsSiteUrl
}

function configureMapredSite()
{
 mapredSiteUrl=$1

 cp $mapredSiteUrl.template $mapredSiteUrl
 
 n=`sed -n -e "/<configuration>/="  $mapredSiteUrl`
 sed -i "`expr $n + 1`d" $mapredSiteUrl
 sed -i "/^<\/configuration>/d" $mapredSiteUrl

 #mapreduce的框架
 echo "  <property>" >> $mapredSiteUrl
 echo "      <name>mapreduce.framework.name</name>" >> $mapredSiteUrl
 echo "      <value>yarn</value>" >> $mapredSiteUrl
 echo "  </property>" >> $mapredSiteUrl

 #jobhistory的地址
 echo "  <property>" >> $mapredSiteUrl
 echo "      <name>mapreduce.jobhistory.address</name>" >> $mapredSiteUrl
 echo "      <value>node1:10020</value>" >> $mapredSiteUrl
 echo "  </property>" >> $mapredSiteUrl

 #jobhistory的webapp地址
 echo "  <property>" >> $mapredSiteUrl
 echo "      <name>mapreduce.jobhistory.webapp.address</name>" >> $mapredSiteUrl
 echo "      <value>node1:19888</value>" >> $mapredSiteUrl
 echo "  </property>" >> $mapredSiteUrl

 echo "</configuration>" >> $mapredSiteUrl
}

function configureYarnSite()
{
 yarnSiteUrl=$1

 n=`sed -n -e "/<configuration>/="  $yarnSiteUrl`
 sed -i "`expr $n + 1`d" $yarnSiteUrl
 sed -i "/^<\/configuration>/d" $yarnSiteUrl

 #nodemanager的aux-services
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.nodemanager.aux-services</name>" >> $yarnSiteUrl
 echo "      <value>mapreduce_shuffle</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 #nodemanager的aux-service类配置
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>" >> $yarnSiteUrl
 echo "      <value>org.apache.hadoop.mapred.ShuffleHandler</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 #resourcemanager的地址
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.resourcemanager.address</name>" >> $yarnSiteUrl
 echo "      <value>node1:8032</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 #resourcemanager的scheduler地址
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.resourcemanager.scheduler.address</name>" >> $yarnSiteUrl
 echo "      <value>node1:8030</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 #resourcemanager的resource-tracker地址
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.resourcemanager.resource-tracker.address</name>" >> $yarnSiteUrl
 echo "      <value>node1:8031</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 #resourcemanager的admin地址
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.resourcemanager.admin.address</name>" >> $yarnSiteUrl
 echo "      <value>node1:8033</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 #resourcemanager的webapp地址
 echo "  <property>" >> $yarnSiteUrl
 echo "      <name>yarn.resourcemanager.webapp.address</name>" >> $yarnSiteUrl
 echo "      <value>node1:8088</value>" >> $yarnSiteUrl
 echo "  </property>" >> $yarnSiteUrl

 echo "</configuration>" >> $yarnSiteUrl
}

function configureSlaves()
{
 slavesUrl=$1
 
 sed -i 's/^[^#]/#&/' $slavesUrl
 
 echo "node1" >> $slavesUrl
 echo "node2" >> $slavesUrl
 echo "node3" >> $slavesUrl
}

function installHadoop()
{
 #1.在frames.txt中查看是否需要安装hadoop
 hadoopInfo=`egrep "^hadoop" /home/hadoop/automaticDeploy/frames.txt`
 
 hadoop=`echo $hadoopInfo | cut -d " " -f1`
 isInstall=`echo $hadoopInfo | cut -d " " -f2`

 echo $hadoop
 echo $isInstall

 #是否安装
 if [[ $isInstall = "true" ]];then

   #2.查看/opt/frames目录下是否有hadoop安装包
   hadoopIsExists=`find /opt/frames -name $hadoop`
   echo $hadoopIsExists
   if [[ ${#hadoopIsExists} -ne 0  ]];then
     
       if [[ ! -d /opt/app ]];then
           mkdir /opt/app && chmod -R 775 /opt/app
       fi 

       #删除旧的
       hadoop_home_old=`find /opt/app -maxdepth 1 -name "hadoop*"`
       for i in $hadoop_home_old;do
           rm -rf $i
       done

       #3.解压到指定文件夹/opt/app中
       echo "开始解压hadoop安装包"
       tar -zxvf $hadoopIsExists -C /opt/app >& /dev/null
       echo "hadoop安装包解压完毕"

       hadoop_home=`find /opt/app -maxdepth 1 -name "hadoop*"`
       
       #4.在hadoop安装目录下创建tmp、name和data目录
       if [[ ! -d $hadoop_home/tmp ]];then
           mkdir $hadoop_home/tmp
       fi
       if [[ ! -d $hadoop_home/name ]];then
           mkdir $hadoop_home/name
       fi
       if [[ ! -d $hadoop_home/data ]];then
           mkdir $hadoop_home/data
       fi

       chmod -R 775 $hadoop_home
  
       #5.配置hadoop-env.sh文件
       java_home=`egrep "^export JAVA_HOME=" /etc/profile`
       echo "" >> $hadoop_home/etc/hadoop/hadoop-env.sh
       echo "$java_home" >> $hadoop_home/etc/hadoop/hadoop-env.sh
       echo "export PATH=\$PATH:$hadoop_home/bin" >> $hadoop_home/etc/hadoop/hadoop-env.sh
       #source $hadoop_home/etc/hadoop/hadoop-env.sh
       
       #6.配置yarn-env.sh文件
       num=`sed -n -e "/# export JAVA_HOME=/="  $hadoop_home/etc/hadoop/yarn-env.sh`  
       sed -i "${num}a ${java_home}" $hadoop_home/etc/hadoop/yarn-env.sh
 
       #7.配置core-site.xml文件
       configureCoreSite $hadoop_home/etc/hadoop/core-site.xml
 
       #8.配置hdfs-site.xml
       configureHdfsSite $hadoop_home/etc/hadoop/hdfs-site.xml

       #9.配置mapred-site.xml
       configureMapredSite $hadoop_home/etc/hadoop/mapred-site.xml

       #10.配置yarn-site.xml
       configureYarnSite $hadoop_home/etc/hadoop/yarn-site.xml

       #11.配置slaves
       configureSlaves $hadoop_home/etc/hadoop/slaves
   fi
 fi
}

installHadoop
