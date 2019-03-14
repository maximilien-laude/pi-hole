#!/bin/sh

if [[ -e "/var/lib/pihole-system" ]];then

        tar -C /var/lib/pihole-system -xvf /root/pihole-system.tar.gz

else

        echo "can't untar"
        exit 1

fi
