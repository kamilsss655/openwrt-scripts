#!/bin/sh /etc/rc.common

# 2019 by Kamil Cyrkler, MIT

# Send e-mail when matching syslog events happen.
# It can send e-mail when:
#  * snort detects a threat
#  * failed SSH login attempt
#  * client connects to WIFI network
##



EMAIL="example@gmail.com"
PATTERN="DHCPACK\|wifipresence\|snort\|dropbear\|err\|warn\|alert\|emerg\|crit"
LOGFILE_PATH="/var/log/syslog"

START=10
STOP=15

log() {
        tail -Fn0 $LOGFILE_PATH | \
        while read line ; do
                echo "$line" | grep -q $PATTERN
                if [ $? = 0 ]
                then
                        printf "Subject: Router alert\n\n$line" | ssmtp $EMAIL
                fi
        done
}

start() {
        log &
}

stop() {
        echo "stop"
}
