#! /bin/bash

hostname=$1

#1.ip地址修改，目前只能每台机器独自修改ip地址
echo "1.ip地址修改暂无"

#2.修改机器名hostname
echo "2.修改hostname为node1"
/home/hadoop/automaticDeploy/systems/changeHostname.sh $hostname

#3.host配置文件修改
echo "3.把集群ip及其映射的hostname添加到/etc/hosts中"
/home/hadoop/automaticDeploy/systems/addClusterIps.sh

#4.关闭防火墙、SELINUX ，需要输入参数close或start
echo "4.关闭防火墙、SELINUX"
/home/hadoop/automaticDeploy/systems/closeFirewall.sh close

#5.添加bigdata用户名 ，需要输入参数create或delete
echo "5.添加bigdata用户名"
/home/hadoop/automaticDeploy/systems/autoCreateUser.sh create

#6.配置yum源
echo "6.配置yum源"
/home/hadoop/automaticDeploy/systems/configureYum.sh $hostname

#7.配置SSH无密码登录
echo "7.集群各节点之间配置SSH无密码登录"
/home/hadoop/automaticDeploy/systems/sshFreeLogin.sh

#8.配置JDK环境
echo "8.配置jdk环境"
/home/hadoop/automaticDeploy/systems/configureJDK.sh

#9.配置SCALA环境
echo "9.配置scala环境"
/home/hadoop/automaticDeploy/systems/configureScala.sh

echo ""