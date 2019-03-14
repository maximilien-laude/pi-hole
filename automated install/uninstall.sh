#!/usr/bin/env bash

source "/var/lib/pihole-system/opt/pihole/COL_TABLE"

if [ "$(id -u)" -ne 0 ]; then

        echo "[!] This script must run as root" >&2
        exit 1

else

	readonly PI_HOLE_FILES_DIR="/var/lib/pihole-system/etc/.pihole"
	PH_TEST="true"
	source "${PI_HOLE_FILES_DIR}/automated install/basic-install.sh"
	# setupVars set in basic-install.sh
	source "${setupVars}"

	# distro_check() sourced from basic-install.sh
	distro_check

	DEPS=("${PIHOLE_DEPS[@]}")
	if [[ "${INSTALL_WEB_SERVER}" == true ]]; then
    	# Install the Web dependencies
    		DEPS+=("${PIHOLE_WEB_DEPS[@]}")
	fi

	package_check() {

        	dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -c "ok installed"

	}

 	# Purge dependencies
    	echo ""
    	for i in "${DEPS[@]}"; do
        
                echo -ne "  ${INFO} Removing ${i}..."
                apt -y remove --purge ${i} &> /dev/null
                echo -e "${OVER}  ${INFO} Removed ${i}"

    	done

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

    	rm -f /var/lib/pihole-system &> /dev/null
	rm -f /usr/local/bin/pihole &> /dev/null
        rm -f /etc/bash_completion.d/pihole &> /dev/null
        rm -f /etc/sudoers.d/pihole &> /dev/null
        rm -f /root/pihole-system.tar.gz &> /dev/null
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

	echo "${COL_LIGHT_GREEN}Uninstallation Complete! ${COL_NC}"

fi


