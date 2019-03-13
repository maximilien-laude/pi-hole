#!/bin/sh

if [[ ! -e "/lib/systemd/system-shutdown/save-pihole-files.pl" ]];then

        echo "can't save pihole !"
        exit 1

else

        mount -o remount,rw /
        perl /lib/systemd/system-shutdown/save-pihole-files.pl
        mount -o remount,ro /
        exit 0

fi
