#!/bin/bash
echo "This script will do following."
echo "	1)check whether NIS/LDAP is enabled: run it as <scrupt-name> check"
echo "	2)configute a machine to use LDAP, by disabling NIS: run it as <scrupt-name> ldap"
echo "	3)configute a machine to use NIS, by disabling LDAP: run it as <scrupt-name> nis"

if [ -z "$1" ]
then
exit
fi

logfile=/tmp/client.log
ldapserver=172.31.1.1
nisserver=172.31.1.1
bdn="dc=iitk,dc=ac,dc=in"
domain=cc

echo > $logfile
date >> $logfile
valuematch() {
var1=`grep ^NISDOMAIN /etc/sysconfig/network`
if [ ! -z "$var1" ]
  then
  continue
else
  echo "NISDOMAIN=cc">>/etc/sysconfig/network
fi
}
checkin() {
	ret1=`authconfig --test|grep -w "nss_nis is enabled"`
	ret2=`authconfig --test|grep -w "nss_ldap is enabled"`
      	if [ "$ret1" == "nss_nis is enabled" ]
        then
          echo " This machine is an NIS client"
      	elif [ "$ret2" == "nss_ldap is enabled" ]
        then
            echo "This machine is an LDAP client"
      	else
        echo "this machine is not in NIS/LDAP"
      	fi
}

if [ "$1" == "ldap" ]
  then
    echo "Now making the machine as a LDAP client" >> $logfile
    chkconfig ypbind off
    /etc/init.d/ypbind stop
    sed -ri '/NISDOMAIN/s/.*//' /etc/sysconfig/network
    authconfig --enableldap --disablenis  --disableldaptls --disableldapstarttls --enableldapauth --ldapserver=$ldapserver --ldapbasedn=$bdn --updateall
    chkconfig nslcd on
    chkconfig nscd on
    # unalias cp
    cp --remove-destination nscd.conf /etc/nscd.conf
    /etc/init.d/nscd start
    cp --remove-destination /usr/bin/passwd /usr/bin/passwd.nis
    cp --remove-destination /usr/bin/rootpasswd /usr/bin/passwd
    cp --remove-destination system-auth.ldap /etc/pam.d/system-auth-ac 
    cp --remove-destination password-auth.ldap /etc/pam.d/password-auth-ac
    cp --remove-destination fingerprint-auth.ldap /etc/pam.d/fingerprint-auth-ac
    cp --remove-destination smartcard-auth.ldap /etc/pam.d/smartcard-auth-ac 
elif [ "$1" == "nis" ]
  then
    echo "Now making the machine as a LDAP client" >> $logfile
    valuematch
    ypdomainname $domain
    authconfig --enablenis --disableldap --disableldapauth --nisdomain=$domain --nisserver=$nisserver --update
    chkconfig ypbind on
    chkconfig nslcd off
    chkconfig nscd off
    /etc/init.d/ypbind start
    /etc/init.d/nscd stop	  
    cp --remove-destination /usr/bin/passwd /usr/bin/passwd.system
    cp --remove-destination /usr/bin/yppasswd /usr/bin/passwd
    cp --remove-destination system-auth.nis /etc/pam.d/system-auth-ac 
    cp --remove-destination password-auth.nis /etc/pam.d/password-auth-ac
    cp --remove-destination fingerprint-auth.nis /etc/pam.d/fingerprint-auth-ac
    cp --remove-destination smartcard-auth.nis /etc/pam.d/smartcard-auth-ac 
elif [ "$1" == check ]
  then
	checkin
fi
