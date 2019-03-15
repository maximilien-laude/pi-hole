#!/usr/bin/env bash

source "/var/lib/pihole-system/opt/pihole/COL_TABLE"

if [ "$(id -u)" -ne 0 ]; then

        echo "[!] This script must run as root" >&2
        exit 1

else

	package_check() {

        	dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed"

	}

	# Attempt to preserve backwards compatibility with older versions
    	# to guarantee no additional changes were made to /etc/crontab after
    	# the installation of pihole, /etc/crontab.pihole should be permanently
    	# preserved.
    	if [[ -f /etc/crontab.orig ]]; then

        	mv /etc/crontab /etc/crontab.pihole
         	mv /etc/crontab.orig /etc/crontab
        	service cron restart
        	echo -e "  ${TICK} Restored the default system cron"
    	fi

    	# Attempt to preserve backwards compatibility with older versions
    	if [[ -f /etc/cron.d/pihole ]];then

         	rm -f /etc/cron.d/pihole &> /dev/null
        	echo -e "  ${TICK} Removed /etc/cron.d/pihole"

	fi

    	package_check lighttpd > /dev/null
    	if [[ $? -eq 1 ]]; then

        	 rm -rf /etc/lighttpd/ &> /dev/null
        	 echo -e "  ${TICK} Removed lighttpd"

    	else

        	if [ -f /etc/lighttpd/lighttpd.conf.orig ]; then

            		 mv /etc/lighttpd/lighttpd.conf.orig /etc/lighttpd/lighttpd.conf

        	fi

    	fi

    	rm -rf /var/lib/pihole-system &> /dev/null
	rm -rf /usr/local/bin/pihole &> /dev/null
        rm -rf /etc/bash_completion.d/pihole &> /dev/null
        rm -rf /etc/sudoers.d/pihole &> /dev/null
        rm -rf /root/pihole-system.tar.gz &> /dev/null
	rm -rf /lib/systemd/system-shutdown/* &> /dev/null
	unlink /etc/pihole &> /dev/null
        unlink /etc/dnsmasq.d &> /dev/null
        unlink /var/log &> /dev/null
        mkdir -p /var/log &> /dev/null
        echo -e "  ${TICK} Removed config files"

	# Remove FTL
    	if command -v pihole-FTL &> /dev/null; then

        	echo -ne "  ${INFO} Removing pihole-FTL..."

        	if [[ -x "$(command -v systemctl)" ]]; then

        		systemctl stop pihole-FTL

        	else

            		service pihole-FTL stop

        	fi

		rm -f /etc/init.d/pihole-FTL
        	rm -f /usr/bin/pihole-FTL
        	echo -e "${OVER}  ${TICK} Removed pihole-FTL"

    	fi

	if [[ -f /usr/local/share/man/man8/pihole.8 ]]; then

        	rm -f /usr/local/share/man/man8/pihole.8 /usr/local/share/man/man8/pihole-FTL.8 /usr/local/share/man/man5/pihole-FTL.conf.5
        	mandb -q &>/dev/null
        	echo -e "  ${TICK} Removed pihole man page"
    	fi

       	if id "pihole" &> /dev/null; then

	    if ${SUDO} userdel -r pihole 2> /dev/null; then
            	echo -e "  ${TICK} Removed 'pihole' user"

	    else

	    	echo -e "  ${CROSS} Unable to remove 'pihole' user"

	    fi
    	fi
	
	if [[ -f "/usr/sbin/save-pihole-files.pl" ]]; then
    		
		rm -rf /usr/sbin/save-pihole-files.pl  &> /dev/null	
	
	fi
    
	if [[ -f "/usr/sbin/pihole-untar.sh" ]]; then
    
        	rm -rf /usr/sbin/pihole-untar.sh &> /dev/null
  
    	fi
	
	if [[ -f "/lib/systemd/system/pihole-untar-boot.service" ]]; then 
    
        	systemctl disable pihole-untar-boot.service &> /dev/null
          	systemctl daemon-reload
		rm -rf /lib/systemd/system/pihole-untar-boot.service &> /dev/null
    
    	fi
	
	if [[ -f "/lib/systemd/system/pihole-shutdown-save.service" ]]; then
    
        	systemctl enable pihole-shutdown-save.service &> /dev/null
         	systemctl daemon-reload
    		rm -rf /lib/systemd/system/pihole-shutdown-save.service &> /dev/null
    	fi
	
	if df -h | grep -oP '(/var/lib/php/sessions)'; then
      
        	sed -i "\@^tmpfs  /var/lib/php/sessions   tmpfs defaults,noatime,nosuid,nodev,size=50K 0 0@d" /etc/fstab
      
      	fi

	if df -h | grep -oP '(/var/lib/pihole-system)'; then
      
        	sed -i "\@^tmpfs  /var/lib/pihole-system  tmpfs defaults,noatime,nosuid,mode=0755,size=200m  0  0@d" /etc/fstab
      
      	fi
	
	echo "${COL_LIGHT_GREEN}Uninstallation Complete! ${COL_NC}"
	shutdown -r 0

fi




