#! /bin/bash

function configureJDK()
{

 version=$1

 #1.查找/opt/frames目录下是否有jdk安装包
 javaIsExists=`find /opt/frames -name "jdk*$version*"`

 if [[ ${#javaIsExists} -ne 0 ]];then
 
    if [ -d /usr/lib/java ];then
       rm -rf /usr/lib/java
    fi
 
    mkdir /usr/lib/java && chmod -R 777 /usr/lib/java
   
    #2.解压到指定文件夹/usr/lib/java中 
    echo "开启解压jdk安装包"
    tar -zxvf $javaIsExists -C /usr/lib/java >& /dev/null
    echo "jdk安装包解压完毕"

    java_home=`find /usr/lib/java -name "jdk*$version*"` 

    #3.在/etc/profile配置JAVA_HOME
    profile=/etc/profile
    
    sed -i "/^export JAVA_HOME/d" $profile
    echo "export JAVA_HOME=$java_home" >> $profile
 
    #4.在/etc/profile配置PATH
    sed -i "/^export PATH=\$PATH:\$JAVA_HOME\/bin/d" $profile
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $profile
    sed -i "/^export CLASSPATH=.:\$JAVA_HOME/d" $profile
    echo "export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> $profile

    #5.更新/etc/profile文件
    source /etc/profile && source /etc/profile
    #不需要
    #pathIsExists=`grep "^export PATH=" $profile`
    #java_homeIsExists=`grep "^export PATH=" $profile | grep "JAVA_HOME/bin"`
    #if [[ -z $java_homeIsExists ]];then
    #     if [[ -z $pathIsExists ]];then
    #        echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> $profile
    #     else
    #        sed -i 's/^export PATH=.*/&:\$JAVA_HOME\/bin/' $profile
    #     fi
    # fi
 else 
     echo "/opt/frames目录下没有jdk$version安装包"
 fi
}

configureJDK 8
