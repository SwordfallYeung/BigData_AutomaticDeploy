#! /bin/bash

function configureScala()
{
 version=$1

 #1.查找/opt/frames目录下是否有Scala安装包
 scalaIsExists=`find /opt/frames -name "scala*$version*"`

 if [[ ${#scalaIsExists} -ne 0 ]];then
    
    if [ -d /usr/lib/scala ];then
       rm -rf /usr/lib/scala
    fi

    mkdir /usr/lib/scala && chmod -R 777 /usr/lib/scala

    #2.解压到指定文件夹/usr/lib/scala中
    echo "开始解压scala安装包"
    tar -zxvf $scalaIsExists -C /usr/lib/scala >& /dev/null
    echo "scala安装包解压完毕"

    scala_home=`find /usr/lib/scala -type d  -name "scala*$version*"`
    
    #3.在/etc/profile配置SCALA_HOME
    profile=/etc/profile
    sed -i "/^export SCALA_HOME/d" $profile
    echo "export SCALA_HOME=$scala_home" >> $profile

    #4.在/etc/profile配置PATH
    sed -i "/^export PATH=\$PATH:\$SCALA_HOME\/bin/d" $profile
    echo "export PATH=\$PATH:\$SCALA_HOME/bin" >> $profile

    #5.更新/etc/profile文件
    source /etc/profile && source /etc/profile  

    #不需要
    #pathIsExists=`grep "^export PATH=" $profile`
    #scala_homeIsExists=`grep "^export PATH=" $profile | grep "SCALA_HOME/bin"`
    #if [[ -z $scala_homeIsExists ]];then
    #    if [[ -z $pathIsExists ]];then
    #       echo "export PATH=\$PATH:\$SCALA_HOME/bin" >> $profile
    #    else
    #       sed -i 's/^export PATH=.*/&:\$SCALA_HOME\/bin/' $profile
    #    fi
    #fi
 else 
     echo "/opt/frames目录下没有scala$version安装包"
 fi
}

configureScala 2.11
