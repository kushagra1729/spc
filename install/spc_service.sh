#!/bin/bash
# /usr/bin/./spc_daemon
while true
do
	# xhost + >& /dev/null
	# zenity --question --display=:0 --text="Do you wish to sync now?" --title="SPC"
	# if [ $? -eq 0 ]
	if [ true ]
		then
		spc syncdown
		# notify-send 'Sync completed' --display=:0.0 
	fi
	sleep 30;
done
