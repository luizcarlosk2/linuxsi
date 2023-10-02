#!/bin/bash

# Installation:
#
# 1.   vim /etc/ssh/sshd_config
#      PrintMotd no
#
# 2.   vim /etc/pam.d/login
#      # session optional pam_motd.so
#
# 3.   vim /etc/profile
#      /path/to/script.sh # Place at the bottom
#
# 4.   Then of course drop this file at
#      /path/to/script.sh
#
#Requirements:
	#lm-sensors (for CPU Temp)
		#Debian: apt-get install lm-sensors
		#RHEL: yum install lm_sensors
        #lsb_release
                #Debian: apt-get install lsb-core
                #RHEL: yum isntall redhat-lsb-core
#Optional Requirements:
	#Fail2ban

#----------------------------------------------------------------
#Timeout in seconds, to avoid long hang in ssh login:
Timeout=10

function timeout_monitor() {
   sleep "$Timeout"
   kill "$1"
}
# start the timeout monitor in 
# background and pass the PID:
timeout_monitor "$$" &
Timeout_monitor_pid=$!

#To test timeout:
#sleep 40
#---------------------------------------------------------------

USER=`whoami`
HOSTNAME=`uname -n`
KERNEL=`uname -sr`
ALLUSERS=`who`

OS_DIS=$(lsb_release -si)
OS_VER=$(lsb_release -sr)
OS_ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')



#Number of Processors/Threads
nproc=`nproc`

#CPU Load Average last 1 minute
load_1m=`cat /proc/loadavg | awk '{print $1}'`

#CPU Load Average last 1 minute
load_5m=`cat /proc/loadavg | awk '{print $2}'`

#CPU Load Average last 1 minute
load_15m=`cat /proc/loadavg | awk '{print $3}'`



#CPU Load Avarage last 1 minute in Percent
load_1mp=$(awk "BEGIN {printf \"%.0f\",${load_1m}/${nproc}*100}")


#CPU Load Avarage last 1 minute in Percent
load_5mp=$(awk "BEGIN {printf \"%.0f\",${load_5m}/${nproc}*100}")


#CPU Load Avarage last 1 minute in Percent
load_15mp=$(awk "BEGIN {printf \"%.0f\",${load_15m}/${nproc}*100}")

#MEMORY
mem_total=`free -m | egrep Mem | awk '{print $2}'`
mem_used=`free -m | egrep "Mem" | awk '{print $3}'`
mem_free=`free -m | egrep "Mem" | awk '{print $4}'`
mem_cache=`free -m | egrep "Mem" | awk '{print $6}'`
mem_free=$(awk "BEGIN {printf ${mem_free}+${mem_cache}}")

#% Memory Usage
#memory_usage=`free -m | egrep Mem | awk '{ total = $4 / ($4+$3) *100 } {printf("%3.1f%%", total)}'`
mem_perc=$(awk "BEGIN {printf \"%.0f%%\",${mem_used}/${mem_total}*100}")

#Swap
swap_total=`free -m | egrep Swap | awk '{print $2}'`
swap_used=`free -m | egrep Swap | awk '{print $3}'`
swap_free=`free -m | egrep Swap | awk '{print $4}'`
swap_perc=`free -m | awk '/Swap/ { printf("%.0f%%", $3/$2*100) }'`



##ROOT AND HOME PARTITION SIZES
#ROOT_TOTAL=`df -Ph / | tail -1 | awk '{print $2}'`
#ROOT_USED=`df -Ph / | tail -1 | awk '{print $3}'`
#ROOT_AVAIABLE=`df -Ph / | tail -1 | awk '{print $4}'`
#ROOT_PERCENT_USED=`df -Ph / | tail -1 | awk '{print $5}'`

#HOME_TOTAL=`df -Ph /home | tail -1 | awk '{print $2}'`
#HOME_USED=`df -Ph /home | tail -1 | awk '{print $3}'`
#HOME_AVAIABLE=`df -Ph /home | tail -1 | awk '{print $4}'`
#HOME_PERCENT_USED=`df -Ph /home | tail -1 | awk '{print $5}'`

##New Lines - used in NUC
#STORAGE_TOTAL=`df -Ph /mnt/InternalStorage | tail -1 | awk '{print $2}'`
#STORAGE_USED=`df -Ph /mnt/InternalStorage | tail -1 | awk '{print $3}'`
#STORAGE_AVAILABLE=`df -Ph /mnt/InternalStorage | tail -1 | awk '{print $4}'`
#STORAGE_PERCENT_USED=`df -Ph /mnt/InternalStorage | tail -1 | awk '{print $5}'`

DISKS=`lsblk -S | awk -v OFS='\t' '{print $1, $3, $7, $4, $5}'`

STORAGE=`lsblk -m -o NAME,FSTYPE,SIZE,MOUNTPOINT,FSSIZE,FSUSED,FSAVAIL,FSUSE%`


PSA=`ps -Afl | wc -l`

# time of day
HOUR=$(date +"%H")
if [ $HOUR -lt 12  -a $HOUR -ge 0 ]
then    TIME="morning"
elif [ $HOUR -lt 17 -a $HOUR -ge 12 ] 
then    TIME="afternoon"
else 
    TIME="evening"
fi

#System uptime
uptime=`cat /proc/uptime | cut -f1 -d.`
upDays=$((uptime/60/60/24))
upHours=$((uptime/60/60%24))
upMins=$((uptime/60%60))
upSecs=$((uptime%60))


#CPU Temperature:
cputemp=`sensors | egrep Core`

#External IP
#EXTERNALIP=`curl -s ipecho.net/plain ; echo`
#EXTERNALIP=`dig +short myip.opendns.com @resolver1.opendns.com`
EXTERNALIPV4=`dig +short txt ch whoami.cloudflare @1.0.0.1 | sed 's/["]//g'`
EXTERNALIPV6=`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'`


#Fail2ban
fail2ban_log_exist=0
fail2ban_log_readble=0

if [ -f /var/log/fail2ban.log ]
then
  fail2ban_log_exist=1
else
  fail2ban_log_exist=0
fi



if [ -r /var/log/fail2ban.log ]
then
  fail2ban_log_readble=1
else
  fail2ban_log_readble=0
fi

#echo $fail2ban_log_exist
#echo $fail2ban_log_readble



echo "

Good $TIME $USER"

echo "
===========================================================================
- Hostname............: $HOSTNAME
- External IPv4.......: $EXTERNALIPV4
- External IPv6.......: $EXTERNALIPV6
- Distro/Ver/Arch.....: $OS_DIS / $OS_VER / $OS_ARCH bits
- Kernel..............: $KERNEL
- Current user........: $USER
- Processes...........: $PSA running
- System uptime.......: $upDays days $upHours hours $upMins minutes $upSecs seconds
===========================================================================
                         1 Min	5 Min	15 Min
- CPU Load............: $load_1mp%	$load_5mp%	$load_15mp%
- CPU Temperature:
$cputemp
===========================================================================
                        Util	Total	Used	Free
- RAM.................: $mem_perc	$mem_total	$mem_used	$mem_free
- Swap................: $swap_perc	$swap_total	$swap_used	$swap_free
===========================================================================
DISKS AVAILABLES:
$DISKS

DISKS UTILIZATION:
$STORAGE
===========================================================================
- Users...............: Currently `users | wc -w` user(s) logged on
$ALLUSERS
===========================================================================
"


# kill timeout monitor when terminating:
kill "$Timeout_monitor_pid"% 