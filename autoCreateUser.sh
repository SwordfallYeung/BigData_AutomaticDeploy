#! /bin/bash
echo "start to create user 'bigdata'!"

#创建bigdata用户组，创建bigdata用户并设置密码
user=bigdata
group=bigdata1

#create group if not exists 
#在/etc/group中查找用户组是否存在，并把错误输出输到/dev/null中
egrep "^$group" /etc/group >& /dev/null
# 判断上一命令是否等于0，不等于则创建用户组
if [ $? -ne 0 ] 
then
    groupadd $group
fi

#create user if not exists
egrep "^$user" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then 
    useradd -g $group $user
fi

# passwd bigdata

#删除bigdata用户，删除bigdata用户组
userdel -r $user
if [ $user != $group ]
then
   groupdel $group
fi



