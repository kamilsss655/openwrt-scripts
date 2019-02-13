#!/bin/sh /etc/rc.common

# 2019 by Kamil Cyrkler, MIT

# Detect when wifi clients disconnect from network. Can be used to detect clients leaving the AP area.

# DHCP_LEASE TEMP FILE PATH (create manually before running)
BEFORE_PATH="/mnt/sda1/tmp/before_dhcp"
# DHCP_LEASE TEMP FILE PATH (create manually before running)
NOW_PATH="/mnt/sda1/tmp/now_dhcp"
# REFRESH RATE IN SECONDS
REFRESH=3

mac_list()
{
        iwinfo $1 assoclist | grep '[0-9A-F]\{2\}\(:[0-9A-F]\{2\}\)\{5\}' | cut -d' ' -f1
}

monitor()
{
        while true; do
                DHCPLEASE="$(cat /tmp/dhcp.leases)"
                BEFORE=$(mac_list $1)
                sleep 3
                NOW=$(mac_list $1)
                echo "$BEFORE" > "$BEFORE_PATH.$1"
                echo "$NOW" > "$NOW_PATH.$1"
                MAC_LEFT=$(grep -vf "$NOW_PATH.$1" "$BEFORE_PATH.$1")
                if [ ! -z "$MAC_LEFT" -a "$MAC_LEFT" != " " ]; then
                        FRIENDLY_NAME=$(echo "$DHCPLEASE"|grep $MAC_LEFT -i)
                        logger -s -t  "wifipresence" "Device MAC: $MAC_LEFT DHCP: $FRIENDLY_NAME has left."
                fi
        done
}

echo "Press Ctrl+Z to stop."

#monitor "wlan1"
monitor "wlan1"
