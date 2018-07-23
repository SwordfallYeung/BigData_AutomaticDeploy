#! /bin/bash

function remoteChangeHostname()
{
 #1.判断pssh工具是否存在
 psshIsExists=`rpm -qa | grep pssh`
 if [ -z $psshIsExists ]
 then
     yum -y install pssh
 fi
}

remoteChangeHostname
