#!/bin/bash
##01. disable SELINUX
printf "do you want to disable selinux (Y/N)[N]: "
read flagse
if [ "$flagse" == "Y" ]; then
	#line=`awk  '/^SELINUX=/{print $0}' /etc/selinux/config`
	line=$(awk  '/^SELINUX=/{print $0}' /etc/selinux/config)
	if [ "$line" == "SELINUX=enforcing" ]; then
		#awk -F= '$1 == "SELINUX" {$2 ="disabled"}1' OFS== /etc/selinux/config > /tmp/file && mv -f /tmp/file /etc/selinux/config
		#awk -F= '{ $2 = ($1 == "SELINUX" ? "disabled":$2) }1' OFS== /etc/selinux/config > /tmp/file && mv -f /tmp/file /etc/selinux/config
		awk '!/SELINUX=enforcing/{print} /SELINUX=enforcing/{print "SELINUX=disabled"}' /etc/selinux/config > /tmp/file && mv -f /tmp/file /etc/selinux/config
	fi
fi


### 02. disable firewalld
printf "do you want disable firewalld (Y/N)[N]: "
read flagfi
if [ "$flagfi" == "Y" ]; then
	systemctl stop firewalld
	systemctl mask firewalld
fi

## 03. Set Ip address
printf "do you want to set Static IP address (Y/N)[N]: "
read flagA
if [ "$flagA" == "Y" ]; then
	printf "name of the interface to allot a static IP: "
	read ethname
	printf "enter IP address: "
	read ipaddr
	#printf " IS IP address $ipaddr Ok (Y/N)[Y]: "
	printf " IS IP address %s Ok (Y/N)[Y]: " "$ipaddr"
	read flagok
	if [ "$flagok" == "N" ]; then
		printf "enter IP address: "
		read ipaddr
	fi
	#cp --remove-destination /etc/sysconfig/network-scripts/ifcfg-$ethname /etc/sysconfig/network-scripts/ifcfg-$ethname.old
	echo "TYPE=Ethernet" > /etc/sysconfig/network-scripts/ifcfg-"$ethname"
	{
	echo "BOOTPROTO=static"
	echo "IPV6INIT=no"
	echo "IPV6_AUTOCONF=no"
	echo "DEFROUTE=yes"
	echo "NAME=$ethname"
	echo "DEVICE=$ethname" 
	echo "ONBOOT=yes" 
	echo "IPADDR=$ipaddr"
	echo "NETMASK=255.255.0.0"
	echo "GATEWAY=172.31.1.250"
	echo "DNS1=172.31.1.1"
	echo "DNS2=172.31.1.130"
	echo "SEARCH='iitk.ac.in cc.iitk.ac.in'"
	} >> /etc/sysconfig/network-scripts/ifcfg-"$ethname"
	#echo "PEERDNS=no" >> /etc/sysconfig/network-scripts/ifcfg-$ethname  ##prevent modificaion of DNS settings in resolv.onf.
fi

### 04. set hostname
printf " Set Host name (Y/N)[N]: "
read flaghost
if [ "$flaghost" == "Y" ]; then
printf "Set hostname(FQDN) to: "
read hostn
/bin/hostnamectl set-hostname "$hostn"
mcname=$(echo "$hostn"|awk -F. '{print $1}')
if [ -z "$ipaddr" ]; then
	ipaddr=$(ip route get 172.31.1.1 | awk 'NR==1 {print $NF}')
fi

line1=$(grep "$ipaddr" /etc/hosts)
if [ -z "$line1" ]; then
	echo "$ipaddr $hostn $mcname" >> /etc/hosts
fi
fi

### 05. disable IPV6
present=$(grep "disable_ipv6" /etc/sysctl.conf)
if [ -z "$present" ]; then
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
	echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
	sysctl -p
fi
sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
linessh=$(grep "^ListenAddress 0.0.0.0" /etc/ssh/sshd_config)
if [ -z "$linessh" ]; then
	echo "AddressFamily inet" >> /etc/ssh/sshd_config
	echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config
	systemctl restart sshd
fi




### 06. Set local repos
printf "do you want to connect to local repo (Y/N)[N]: "
read flagrepo
if [ "$flagrepo" == "Y" ]; then
	if [ ! -d "/etc/yum.repos.d/repos" ]; then
		mkdir -p /etc/yum.repos.d/repos
	fi
	cd /etc/yum.repos.d/
	#for i in `ls *.repo`
	for i in *.repo
	do
		mv -f "$i" /etc/yum.repos.d/repos/
	done
	curl -O https://linux.cc.iitk.ac.in/mirror/centos/iitk-centos7.repo
	yum clean all
	yum -y update
fi

### 07. Install basic packages
printf "do you want basic utilities (Y/N)[N]: "
read flagutil
if [ -e "/etc/yum.repos.d/CentOS-Base.repo" ]; then
        mv -f /etc/yum.repos.d/CentOS* /etc/yum.repos.d/repos/
fi

if [ "$flagutil" == "Y" ]; then
	echo "wait for basic packages being installed..."
	yum -y install telnet bind-utils curl openssh-server unzip unrar htop iotop iptraf iftop dstat saidar ipmitool vim-x11 vim expect wget man mlocate svn ntpdate net-tools system-storage-manager ntp epel-release lsof redhat-lsb sysstat lshw screen hwdata lm_sensors strace lynx openldap-clients yum-utils ftop psacct inotify-tools
fi
	

printf "do you need Basic X System (Y/N)[N]: "
read flagX
if [ -e "/etc/yum.repos.d/epel.repo" ]; then
	mv -f /etc/yum.repos.d/{epel.repo,epel-testing.repo} /etc/yum.repos.d/repos/
fi
if [ "$flagX" == "Y" ]; then
	yum -y groupinstall "X Window System"
	yum -y install firefox
fi

printf "do you need GNOME Desktop (Y/N)[N]: "
read flagD
if [ "$flagD" == "Y" ]; then
	yum groupinstall "GNOME Desktop" "Graphical Administration Tools"
fi

### 08. install IPtable
printf "do you need IPtable (Y/N)[N]: "
read flagI
if [ "$flagI" == "Y" ]; then
	yum -y install iptables-services
fi

### 09. Set Proxy
printf "do you need proxy setup (Y/N)[N]:"
read flagprox
if [ "$flagprox" == "Y" ]; then
        proxy=nknproxy.iitk.ac.in
        #printf "input the proxy server name[nknproxy.iitk.ac.in]: "
        #read proxy
        printf "input the authenticating user: "
        read username
        read -s -p "input authentication password: " upass
        echo "export http_proxy=http://$username:$upass@$proxy:3128" >> /root/.bashrc
	{
        echo "export https_proxy=http://$username:$upass@$proxy:3128"
        echo "export ftp_proxy=http://$username:$upass@$proxy:3128"
        echo 'export no_proxy="172.31.55.22,172.31.55.34,72.31.55.20,72.31.55.22"'
	} >> /root/.bashrc
	source /root/.bashrc
fi

### 10.Disable network manager
printf "do you want disable network Manager (Y/N)[N]: "
read flagnm
if [ "$flagnm" == "Y" ]; then
	systemctl stop NetworkManager
	systemctl disable NetworkManager
fi

## 11. For KVM guest
printf "Is it a KVM guest OS (Y/N)[N]: "
read flagKVM
if [ "$flagKVM" == "Y" ]; then
	yum -y install qemu-guest-agent
	systemctl start qemu-guest-agent
	systemctl enable qemu-guest-agent
fi


### 12. NTP setup
wget http://linux.cc.iitk.ac.in/configs/ntp.conf -P /tmp
cp --remove-destination /tmp/ntp.conf /etc/ntp.conf
systemctl start ntpd
systemctl enable ntpd

### 13. CLamAv setup

printf "do you want clamav (Y/N)[N]: "
read flagav
if [ "$flagav" == "Y" ]; then
	yum install -y clamav clamav-scanner-systemd clamav-update clamav-data-empty
	wget http://linux.cc.iitk.ac.in/configs/freshclam.conf -P /tmp
	wget http://linux.cc.iitk.ac.in/configs/scan.conf -P /tmp
	wget http://linux.cc.iitk.ac.in/configs/freshclam -P /tmp
	cp --remove-destination /tmp/scan.conf /etc/clamd.d/scan.conf
	cp --remove-destination /tmp/freshclam.conf /etc/freshclam.conf
	cp --remove-destination /tmp/freshclam /etc/sysconfig/freshclam
	systemctl start clamd@scan
	systemctl enable clamd@scan
	freshclam -v
fi

### 14. Configure ssh
printf "Do you want to custome log for ssh (Y/N)[N]: "
read flagSSH
if [ "$flagSSH" == "Y" ]; then
	wget http://linux.cc.iitk.ac.in/configs/rsyslog.conf -P /tmp
	wget http://linux.cc.iitk.ac.in/configs/sshd_config -P /tmp
	wget http://linux.cc.iitk.ac.in/configs/ssh -P /tmp
	cp --remove-destination /tmp/rsyslog.conf /etc/rsyslog.conf
	cp --remove-destination /tmp/sshd_config /etc/ssh/sshd_config
	cp --remove-destination /tmp/ssh /etc/logrotate.d/ssh
	systemctl restart rsyslog
fi
