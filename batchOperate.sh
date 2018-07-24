#! /bin/bash

hostname=$1

#1.修改机器名hostname
echo "1.修改hostname为node1"
/home/hadoop/automaticDeploy/changeHostname.sh $hostname

#2.ip地址修改，目前只能每台机器独自修改ip地址
echo "2.ip地址修改暂无"

#3.host配置文件修改
echo "3.把集群ip及其映射的hostname添加到/etc/hosts中"
/home/hadoop/automaticDeploy/addClusterIps.sh

#4.关闭防火墙、SELINUX ，需要输入参数close或start
echo "4.关闭防火墙、SELINUX"
/home/hadoop/automaticDeploy/closeFirewall.sh close

#5.添加bigdata用户名 ，需要输入参数create或delete
echo "5.添加bigdata用户名"
/home/hadoop/automaticDeploy/autoCreateUser.sh delete

#6.配置yum源
/home/hadoop/automaticDeploy/configureYum.sh $hostname

#7.配置SSH无密码登录
echo "6.集群各节点之间配置SSH无密码登录"
#/home/hadoop/automaticDeploy/sshFreeLogin.sh

echo ""
