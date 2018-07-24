#! /bin/bash

hostname=$1

#3.修改机器名hostname
/home/hadoop/automaticDeploy/changeHostname.sh $hostname
#4.ip地址修改，目前只能每台机器独自修改ip地址
#5.host配置文件修改
/home/hadoop/automaticDeploy/addClusterIps.sh
#6.关闭防火墙、SELINUX
#/home/hadoop/automaticDeploy/closeFireWall.sh
#7.添加bigdata用户名
#/home/hadoop/automaticDeploy/autoCreateUser.sh
#8.配置SSH无密码登录
#/home/hadoop/automaticDeploy/sshFreeLogin.sh
