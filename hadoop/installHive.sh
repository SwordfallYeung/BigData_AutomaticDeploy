#! /bin/bash

function configureHiveEnv()
{
 hiveEnvUrl=$1
 hive_home=$2
 
 cp $hiveEnvUrl.template $hiveEnvUrl

 profile=/etc/profile
 java_home=`egrep "^export JAVA_HOME=" $profile`
 hadoop_home=`egrep "^export HADOOP_HOME=" $profile`
 
 echo "$java_home" >> $hiveEnvUrl
 echo "$hadoop_home" >> $hiveEnvUrl
 echo "$hive_home" >> $hiveEnvUrl

}

function configureHiveSite()
{
 hiveSiteUrl=$1
 
 cat >> $hiveSiteUrl <<EOF
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://192.168.187.200:3306/hive?createDatabaseIfNotExist=true&useSSL=false</value>
    <description>JDBC connect string for a JDBC metastore</description>
  </property>
 
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.jdbc.Driver</value>
    <description>Driver class name for a JDBC metastore</description>
  </property>
 
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>root</value>
    <description>username to use against metastore database</description>
  </property>
 
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>admin</value>
    <description>password to use against metastore database</description>
  </property>
</configuration>
EOF
}

function installHive()
{
 #1.在frames.txt中查看是否需要安装hive
 hiveInfo=`egrep "hive" /home/hadoop/automaticDeploy/frames.txt`

 hive=`echo $hiveInfo | cut -d " " -f1`
 isInstall=`echo $hiveInfo | cut -d " " -f2`
 
 #是否安装
 if [[ $isInstall = "true" ]];then
     
     #2.查看/opt/frames目录下是否有hive安装包
     hiveIsExists=`find /opt/frames -name $hive`
    
     if [[ ${#hiveIsExists} -ne 0 ]];then
           
          if [[ ! -d /opt/app ]];then
              mkdir /opt/app && chmod -R 775 /opt/app
          fi
   
          #删除旧的
          hive_home_old=`find /opt/app -maxdepth 1 -name "*hive*"`
          for i in $hive_home_old;do
                rm -rf $i
          done

          #3.解压到指定文件夹/opt/app中
          echo "开始解压hive安装包"
          tar -zxvf $hiveIsExists -C /opt/app >& /dev/null
          echo "hive安装包解压完毕"

          hive_home=`find /opt/app -maxdepth 1 -name "*hive*"`
 
          #4.配置hive-env.sh文件
          configureHiveEnv $hive_home/conf/hive-env.sh $hive_home

	  #5.配置hive-log4j2.properties文件
          cp $hive_home/conf/hive-log4j2.properties.template $hive_home/conf/hive-log4j2.properties

          #6.配置远程登录模式
          configureHiveSite $hive_home/conf/hive-site.xml
          
          #7.安装mysql并配置hive数据库及权限，暂略
   
          #8.配置HIVE_HOME
          profile=/etc/profile
          sed -i "/^export HIVE_HOME/d" $profile
          echo "export HIVE_HOME=$hive_home" >> $profile

          #9.配置PATH
          sed -i "/^export PATH=\$PATH:\$HIVE_HOME\/bin/d" $profile
          echo "export PATH=\$PATH:\$HIVE_HOME/bin" >> $profile

          #10.更新/etc/profile文件
          source /etc/profile && source /etc/profile
     else
         echo "/opt/frames目录下没有hive安装包1"
     fi
 else
     echo "/opt/frames目录下没有hive安装包2"
 fi
}

installHive
