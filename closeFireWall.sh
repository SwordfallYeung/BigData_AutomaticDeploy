#! /bin/bash

function closeFirewallAndGetenforce()
{
 #1.关闭防火墙
 firewallStatus=`firewall-cmd --state`
 if [[ $firewallStatus = "running" ]]
 then
     systemctl stop firewalld.service &&systemctl disable firewalld.service
 fi
 
 #2.关闭getenforce
 getenforceStatus=`getenforce`
 egrep "^SELINUX=enforcing" /etc/selinux/config >& /dev/null
 if [[ $getenforceStatus = "Enforcing" || $? -eq 0 ]]
 then
     sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config 
 fi
 
 #3.重启，使设置生效
 #reboot
}

function startFirewallAndGetenforce()
{
 #1.开启防火墙
 firewallStatus=`firewall-cmd --state`
 if [[ $firewallStatus != "running" ]]
 then
    systemctl enable firewalld.service && systemctl start firewalld.service
 fi

 #2.开启getenforce
 getenforceStatus=`getenforce`
 egrep "^SELINUX=disabled" /etc/selinux/config >& /dev/null
 if [[ $getenforceStatus = "Disabled" || $? -eq 0 ]]
 then
    sed -i 's/^SELINUX=disabled/SELINUX=enforcing/' /etc/selinux/config
 fi

 #3.重启，使设置生效
 #reboot
}

operate=$1

if [ -z $operate ]
then
    echo "参数为空，请输入参数close或start"
else
    if [[ $operate = "close" ]]
    then
        closeFirewallAndGetenforce
    fi
    if [[ $operate = "start" ]]
    then
        startFirewallAndGetenforce
    fi
fi
