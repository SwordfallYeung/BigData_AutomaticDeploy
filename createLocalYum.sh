#! /bin/bash

function mountCentos()
{
 systemUrl=$1
 yumUrl=$2

 #不存在则创建mount的目录
 if [ ! -d /var/iso ]
 then
      mkdir /var/iso
 fi
 
 #挂载系统
 mount -o loop $systemUrl /var/iso

 cd /etc/yum.repos.d/
 
 #查找/etc/yum.repos.d/目录下是否存在.repo结尾的文件
 fileResult=`find /etc/yum.repos.d/ -name "*.repo"`
 for file in $fileResult 
 do
   onlyFile=`find /etc/yum.repos.d -wholename $file.bak`
   if [ -z $onlyFile ]
   then
        mv $file $file.bak
   fi
 done
  
 #只创建一个.repo文件用于配置本地yum源
 result=`find /etc/yum.repos.d/ -name CentOS-Media.repo.bak`
 if [ -z $result ]
 then 
     touch CentOS-Media.repo
 else
     cp CentOS-Media.repo.bak CentOS-Media.repo
 fi
 
 yumFile=/etc/yum.repos.d/CentOS-Media.repo
 
 #1.把该文件非#开头的行注释掉
 sed -i 's/^[^#]/#&/' $yumFile
 #2.配置本地源
 echo "[base]" >> $yumFile
 echo "name=CentOS-Local" >> $yumFile
 echo "baseurl=file:///var/iso" >> $yumFile
 echo "gpgcheck=0" >> $yumFile
 echo "enabled=1" >> $yumFile
 echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7" >> $yumFile 
 #3.清除YUM缓存
 yum clean all
 #4.列出可用的YUM源
 yum repolist
 #5.安装相应的软件
 httpdIsExists=`rpm -qa | grep http`
 if [ -z $httpdIsExists ]
 then
     yum install -y httpd
 fi
 #6.开启httpd使用浏览器访问
 #service httpd start
 systemctl start httpd.service
 #7.将YUM源配置到httpd中，其他的服务器可通过网络访问这个内网中的YUM源
 httpUrl=/var/www/html/CentOS-7.0
 if [ ! -e $httpUrl/lock ]
 then
     cp -r /var/iso $httpUrl
     echo "lock" >> $httpUrl/lock
 fi
 #8.取消先前挂载的镜像 强制取消，哈哈哈哈
 umount -fl /var/iso
 #9.修改yum源指向的地址
 sed -i 's/^baseurl\=file:\/\/\/var\/iso/baseurl\=http:\/\/'$yumUrl'\/CentOS\-7.0/' $yumFile
 #10.清除YUM缓存
 yum clean all
 #11.列出可用的YUM源
 yum repolist
 echo "create the local yum source successfully"
}

mountCentos /opt/system/CentOS-7-x86_64-DVD-1804.iso 192.168.187.201
