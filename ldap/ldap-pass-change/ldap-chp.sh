#!bin/bash
host="172.31.2.84"
rootdit="dc=iitk,dc=ac,dc=in"
dit="ou=People,ou=ce,ou=cc"

if [ $# -ne 3 ]
then
	echo "Invalid number of arguments!"
	echo "Usage: chg-pass username olf-pass new-pass"
	exit
fi

ldapsearch -x -h $host -p 389 -b "$rootdit" -D "uid=$1,$dit,$rootdit" 'uid=$1' -w $2
search_status=$?

if [ $search_status -eq 0 ]
then
	continue
else
	echo  "Please enter correct old password.";
	exit
fi


ldappasswd -x -h $host -p 389 -D "uid=$1,$dit,$rootdit" -a $2 -s $3 -w $2
pass_change_status=$?

if [ $pass_change_status -eq 0 ]
then
	echo "0";
else
	echo  "Found error while resetting your password! Please contact Admin team.";
fi
