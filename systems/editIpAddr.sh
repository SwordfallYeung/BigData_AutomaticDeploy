#! /bin/bash
################
#针对Centos-7.0
################

#处理涉及到IP地址设置的网络文件，备份并创建新的
function doWithNetworkFile()
{
 #1.查找/etc/sysconfig/network-scripts/目录下是否存在ifcfg-ens33文件，存在则重命名为.bak结尾的
 fileResult=`find /etc/sysconfig/network-scripts/ -name "ifcfg-ens33"`

 if [[ $fileResult != "" ]]
 then
     #2.创建一个ifcfg-ens33文件用于配置网络设置
     result=`find /etc/sysconfig/network-scripts -wholename $fileResult.bak`
     if [[ -z $result ]]  
     then        
         mv $fileResult $fileResult.bak
     fi
     cp $fileResult.bak $fileResult
 else
     touch /etc/sysconfig/network-scripts/ifcfg-ens33
 fi
}

#配置ip地址
function configureIpAddr()
{ 
 ip=$1
 gateway=$2
 fileUrl=/etc/sysconfig/network-scripts/ifcfg-ens33 

 #1.把ifcfg-ens33文件非#开头的行注释掉
 sed -i 's/^[^#]/#&/' $fileUrl
 
 UUID=`grep "^#UUID=*" $fileUrl | head -1`
 
 #2.配置内网IP地址
 #连接类型
 echo "TYPE=Ethernet" >> $fileUrl
 #静态IP
 echo "BOOTPROTO=static" >> $fileUrl
 echo "DEFROUTE=yes" >> $fileUrl
 echo "IPV4_FAILURE_FATAL=no" >> $fileUrl
 #IPV6关闭
 echo "IPV6INIT=no" >> $fileUrl
 #配置名字
 echo "NAME=ens33" >> $fileUrl
 #唯一标识
 echo "${UUID:1}" >> $fileUrl
 #网卡名称
 echo "DEVICE=ens33" >> $fileUrl
 #开机即启动网络
 echo "ONBOOT=yes" >> $fileUrl
 #IP地址
 echo "IPADDR=$ip" >> $fileUrl
 echo "PREFIX=24" >> $fileUrl
 #网络掩码
 echo "NETMASK=255.255.255.0" >> $fileUrl
 #网关
 echo "GATEWAY=$gateway" >> $fileUrl 
}

function editIpAddr()
{
 ip=$1
 gateway=$2
 
 #处理涉及到IP地址设置的网络文件，备份并创建新的
 doWithNetworkFile
 #在/etc/sysconfig/network-scripts/ifcfg-ens33上设置IP地址
 configureIpAddr $ip $gateway 
 
 #重启网络服务
 service network restart
}

ip=$1
gateway=$2
editIpAddr $ip $gateway