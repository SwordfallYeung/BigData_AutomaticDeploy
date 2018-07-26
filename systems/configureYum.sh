#! /bin/bash

#配置yum源
function configureYumSource()
{
 yumUrl=$1 
 yumFile=$2
 
 #1.把CentOS-Media.repo文件非#开头的行注释掉
 sed -i 's/^[^#]/#&/' $yumFile
 #2.配置本地源
 echo "[base]" >> $yumFile
 echo "name=CentOS-Local" >> $yumFile
 echo "baseurl=$yumUrl" >> $yumFile
 echo "gpgcheck=0" >> $yumFile
 echo "enabled=1" >> $yumFile
 echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7" >> $yumFile
 #3.清除YUM缓存
 yum clean all > /dev/null 2>&1
 #4.列出可用的YUM源
 yum repolist > /dev/null 2>&1
}

#处理并保证只有一个CentOS-Media.repo文件存在
function doWithRepoFile()
{
 #1.进入到yum.repos.d目录
 cd /etc/yum.repos.d/
 
 #2.查找/etc/yum.repos.d/目录下是否存在.repo结尾的文件，存在则重命名为.repo.bak结尾的
 fileResult=`find /etc/yum.repos.d/ -name "*.repo"`
 for file in $fileResult
 do
   onlyFile=`find /etc/yum.repos.d -wholename $file.bak`
   if [[ -z $onlyFile ]]
   then
        mv $file $file.bak
   fi
 done

 #3.只创建一个.repo文件用于配置本地yum源
 result=`find /etc/yum.repos.d/ -name CentOS-Media.repo.bak`
 if [[ -z $result ]]
 then
     touch CentOS-Media.repo
 else
     cp CentOS-Media.repo.bak CentOS-Media.repo
 fi
}

#############################################################################
#同一函数及其调用的子函数，父函数与子函数均有一样的变量名，而内容不一样会报错
#############################################################################

#配置本地源
function localYumSource()
{
 systemUrl=$1
 ip=$2
 yumFile=/etc/yum.repos.d/CentOS-Media.repo

 #1.不存在则创建mount的目录
 if [ ! -d /var/iso ]
 then
      mkdir /var/iso
 fi
 
 #挂载系统，已挂载则不再次挂载
 if [ ! -d /var/iso/CentOS_BuildTag ]
 then 
     mount -o loop $systemUrl /var/iso
 fi

 #2.处理并保证只有一个CentOS-Media.repo的文件用于配置本地yum源
 doWithRepoFile 

 #3.配置yum源
 configureYumSource file:///var/iso $yumFile

 #4.安装相应的软件
 httpdIsExists=`rpm -qa | grep http`
 if [[ -z $httpdIsExists ]]
 then
     yum install -y httpd
 fi

 #5.开启httpd使用浏览器访问
 #service httpd start
 httpdStatus=`systemctl status httpd.service`
 result=$(echo $httpdStatus | grep "Active: active (running)")
 if [[ $result = "" ]]
 then
     systemctl start httpd.service
 fi
 
 #6.将YUM源配置到httpd中，其他的服务器可通过网络访问这个内网中的YUM源
 httpUrl=/var/www/html/CentOS-7.0
 if [ ! -e $httpUrl/lock ]
 then
     cp -r /var/iso $httpUrl
     echo "lock" >> $httpUrl/lock
 fi
 
 #7.取消先前挂载的镜像 强制取消，哈哈哈哈
 umount -fl /var/iso
 
 #8.修改yum源指向的地址
 sed -i 's/^baseurl\=file:\/\/\/var\/iso/baseurl\=http:\/\/'$ip'\/CentOS-7.0/' $yumFile
 
 #9.清除YUM缓存
 yum clean all > /dev/null 2>&1
 
 #10.列出可用的YUM源
 yum repolist > /dev/null 2>&1
 #echo "create the local yum source successfully"
}

#配置远程yum源
function remoteYumSource()
{
 ip=$1
 yumUrl=http://$ip/CentOS-7.0
 yumFile=/etc/yum.repos.d/CentOS-Media.repo 

 #1.处理并保证只有一个CentOS-Media.repo的文件用于配置yum源
 doWithRepoFile

 #2.配置yum源
 configureYumSource $yumUrl $yumFile
}

hostname=$1

if [[ $hostname = "node1" ]]
then
    localYumSource /opt/system/CentOS-7-x86_64-DVD-1804.iso 192.168.187.201
else
    remoteYumSource 192.168.187.201
fi
