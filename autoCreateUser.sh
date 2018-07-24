#! /bin/bash

#创建bigdata用户组，创建bigdata用户并设置密码
function createUserAndGroup()
{
 echo "start to create user 'bigdata'!"

 user=$1
 group=$2

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

 #在shell中使用expect实现自动输入密码，通常需要与'expect <<EOF EOF'、spawn、子expect一起使用
 expect << EOF
 spawn passwd $user
 expect "New password:"
 send "${user}\r"
 expect "Retype new password:"
 send "${user}\r"
 expect eof;
EOF
}

#删除bigdata用户，删除bigdata用户组
function deleteUserAndGroup()
{
 user=$1
 group=$2

 echo "delete the user:" $user " and the userGroup:" $group
 userdel -r $user
 if [ $user != $group ]
 then
     groupdel $group
 fi
}

operate=$1

if [ -z $operate ]
then
    echo "参数为空，请输入参数create或delete"
else
    if [[ $operate = "create" ]]
    then
        createUserAndGroup bigdata bigdata
    fi
    if [[ $operate = "delete" ]]
    then
        deleteUserAndGroup bigdata bigdata
    fi
fi
