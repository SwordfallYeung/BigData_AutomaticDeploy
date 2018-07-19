#! /bin/bash

function mountCentos()
{
 systemUrl=$1

 #创建mount的目录
 mkdir /var/iso
 mount -o loop $systemUrl /var/iso
 cd /etc/yum.repos.d/
 
 #查找/etc/yum.repos.d/目录下是否存在.repo结尾的文件
 fileResult=`find /etc/yum.repos.d/ -name "*.repo"`
 for file in $fileResult 
 do
   #echo $file
   mv $file $file.bak
 done
  
 #只创建一个.repo文件用于配置本地yum源
 result=`find /etc/yum.repos.d/ -name CentOS-Media.repo.bak`
 #echo $result
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
 echo "enabled=1   #很重要，1才启用" >> $yumFile
 echo "gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7" >> $yumFile 
 #3.清除YUM缓存
 yum clean all
 #4.列出可用的YUM源
 yum repolist
 #5.安装相应的软件
 yum install -y httpd
 #6.开启httpd使用浏览器访问
 service httpd start
 #7.将YUM源配置到httpd中，其他的服务器可通过网络访问这个内网中的YUM源
 cp -r /var/iso /var/www/html/CentOS-7.0
 #8.取消先前挂载的镜像
 umount /var/iso
 
}

mountCentos /opt/system/CentOS-7-x86_64-DVD-1804.iso
