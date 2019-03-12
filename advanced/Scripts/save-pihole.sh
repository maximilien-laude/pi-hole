#!/bin/sh

mount -o remount,rw /
perl /lib/systemd/system-shutdown/save-pihole-files.pl
mount -o remount,ro /
