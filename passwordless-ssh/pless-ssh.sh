#!/bin/bash
#yum install epel-release sshpass
chmod 600 id_rsa.pub
while read ip; do
    sshpass -p 'test' scp -p id_rsa.pub root@$ip:/root/.ssh/authorized_keys
#   rsync -pR --password-file=pass id_rsa.pub root@$ip:/root/.ssh/authorized_keys
done < iplist

#spawn scp .ssh/id_rsa.pub root@172.31.2.228:.ssh/
#expect "*password:"
#send "test\r"

