#!/bin/bash

## install ipmitool if not installed.
X=`rpm -qa| grep -i ipmitool`
if [[ "$X" =~ ^ipmitool* ]]; then
    printf "ipmitool is present"
else 
    printf "Please install ipmitool"
	yum -y install dmidecode ipmitool
    exit
fi


## Function to check and assign IP
ip_set() {
    printf "enter IP address: "
    read ipaddr
    printf " IS IP address %s Ok (Y/N)[Y]: " "$ipaddr"
    read flagok
    if [ "$flagok" == "N" ]; then
        printf "enter IP address: "
        read ipaddr
    fi
    ipmitool lan set 2 ipaddr "$ipaddr"
    ipmitool lan set 2 netmask 255.255.0.0
    ipmitool lan set 2 defgw ipaddr 172.31.1.250
#	ipmitool mc reset cold
#	ipmitool lan set 2 access on
}

see_IP(){
	printf "do you want to see IP status (Y/N)[N]: "
	read Y
	if [ "$Y" == Y ]; then
		ipmitool lan print 2
	fi
}

check_User() {
	printf "List all users(Y/N)[N]: "
        read Z
        if [ "$Z" == "Y" ]; then
		ipmitool user list 2
        fi

}

##01. Assign IP address
printf "do you want to set a static IP address (Y/N)[N]: "
read flagse
if [ "$flagse" == "Y" ]; then
	see_IP
    A=`ipmitool lan print 2|grep "IP Address Source"`
    B=`echo $A|awk -F: '{print $2}'| xargs`
    if [ "$B" == "Static Address" ]; then
        printf "A static address is already presenti: do you want to change it (Y/N)[N]: "
        read flags1
        if [ "$flags1" == Y ]; then
            ip_set
        fi
    fi
    if [ "$B" == "DHCP Address" ]; then
       ipmitool lan set 2 ipsrc static
       ip_set
    fi
fi
see_IP

### 02. List all users. We should have total 2 users admin,mgmt
check_User
printf "do you want to reset user list to default (Y/N)[N]: "
read flagC
if [ "$flagC" == "Y" ]; then	
	C=`ipmitool user summary 2 | grep "Enabled User Count"|awk -F: '{print $2}'| xargs`
	if [ "$C" -le 2 ]; then
		echo "there are toal '$C' number of active users"
		P=`hostname -s| tr '[:lower:]' '[:upper:]'`
		Q=`ifconfig eno1| grep inet|awk '{print $2}'|cut -d. -f4`
		R=`dmidecode | grep -A3 '^System Information'| grep "Manufacturer:"|awk -F: '{print $2}'| xargs`
		
		ipmitool user set name  2 mgmt
		ipmitool user set password 2 "$P$Q-$R"
		ipmitool user priv 2 3 2
	
		ipmitool user set name  1 admin
		ipmitool user set password 1 "$P$Q$R]1"
	else
		printf "You have more than 2 users:Check manually"
	fi
	
fi
