#! /bin/bash

function installFlume()
{
 #1.在frames.txt中查看是否需要安装flume
 flumeInfo=`egrep "^flume" /home/hadoop/automaticDeploy/frames.txt`
 
 flume=`echo $flumeInfo | cut -d " " -f1`
 isInstall=`echo $flumeInfo | cut -d " " -f2`
 
 #是否安装
 if [[ $isInstall = "true" ]];then
    
    #2.查看/opt/frames目录下是否有flume安装包
    flumeIsExists=`find /opt/frames -name $flume`
    if [[ ${#flumeIsExists} -ne 0 ]];then
        if [[ ! -d /opt/app ]];then
            mkdir /opt/app && chmod -R 775 /opt/app
        fi
   
        #删除旧的
        flume_home_old=`find /opt/app -maxdepth 1 -name "flume*"`
        for i in $flume_home_old;do
            rm -rf $i
        done

        #3.解压到指定文件夹/opt/app中
        echo "开始解压flume安装包"
        tar -zxvf $flumeIsExists -C /opt/app >& /dev/null
        echo "flume安装包解压完毕"

        flume_home=`find /opt/app -maxdepth 1 -name "hadoop*"`

        #4.配置FLUME_HOME
        profile=/etc/profile
        sed -i "/^export FLUME_HOME/d" $profile
        echo "export FLUME_HOME=$flume_home" >> $profile

        #5.配置PATH
        sed -i "/^export PATH=\$PATH:\$FLUME_HOME\/bin/d" $profile
        echo "export PATH=\$PATH:\$FLUME_HOME/bin:" >> $profile

        #6.更新/etc/profile文件
        source /etc/profile && source /etc/profile
    else
        echo "/opt/frames目录下没有flume安装包"
    fi
 else
     echo "/opt/frames目录下没有flume安装包"
 fi

}

installFlume
