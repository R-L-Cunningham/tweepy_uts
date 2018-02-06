#!/bin/bash

# This script simplifies the management of starting and stopping Python scripts.
# Author: Mike Lake, Matt Cramp
# Version: 1st February 2018

# Provide help to the user. 
function help {
	echo
	echo "Usage: $0 {start py_script | stop PID | status}"
	echo
	echo Examples: 
	echo ' ' $0 start yahooEx.py
	echo ' ' $0 stop 33412
	echo ' ' $0 status
	echo
}


# Find any PID files.
num_pid_files=`find . -name "*.pid" | wc -l`

# Next line for debugging only.
#echo "num_pid_files=$num_pid_files"

case "$1" in
    start)
        if [ $# -ne 2 ]; then
			echo 'Error: Not enough program args.'
			help
			exit
		fi
		rscript=$2
        if [ $num_pid_files -gt 0 ]; then
			echo "You can't start another instance."
			echo "There seem to be $num_pid_files PID files already."
			exit
		fi
		if [ ! -e $pyscript ]; then
			echo "Error: The script $pyscript was not found."
			help
			exit
		fi
		echo -n "Starting Python script $pyscript ..."
		python $pyscript 2>&1 &
		pid=$!
		echo " PID=$pid"
		date > $pid.pid
    ;;
     
    stop)
        if [ $# -ne 2 ]; then
			echo 'Error: Not enough program args.'
			help
			exit
		fi
		# declare -i pid
		pid=$2

		echo -n "Do you wish to kill process $pid? "
		read REPLY
		if [ -z $REPLY ]; then
   			echo "You didn't enter anything; try again next time."
   			exit 1
		fi

		# If user has NOT selected y/Y then exit.
		if [ $REPLY != "y" ] && [ $REPLY != "Y" ]; then
    		exit 0
		fi

		# Final check, there should be a corresponding PID file. 
		# We won't kill any process unless there is a PID file for it. 
		if [ ! -e ${pid}.pid ]; then
			echo "Error: didn't find PID ${pid}.pid "
			exit 1
		fi
		
		# We got here so should be OK to proceed.
		echo -n "Killing process $pid ... "
		sudo kill -9 $pid
		if [ $? == 0 ]; then 
			echo 'OK'
		else
			echo 'error'
		fi
	
		# TODO add check to only remove processes owned by user.
		echo -n "Removing PID file ${pid}.pid ... "
		rm -f ${pid}.pid 
		if [ $? == 0 ]; then
			echo 'OK'
		else
			echo 'error'
		fi
    ;;
     
    status)
		echo
		echo 'There should be one process and a corresponding PID file.'
		echo
		echo 'Python Processes:'
		ps -C python
		echo 
		echo "PID Files:"
		find . -name "*.pid"
		echo 
    ;;

    *)
		help
    	exit 1
esac

# Misc stuff.
#pidlist=`find . -name "*.pid"`
#echo $pidlist
#for i in $pidlist; do
#	echo `basename $i .pid`
#done

